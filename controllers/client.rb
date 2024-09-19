# frozen_string_literal: true

require 'faraday'
require 'faraday/typhoeus'
require 'json'

require_relative '../components/errors'

module Ollama
  module Controllers
    class Client
      DEFAULT_ADDRESS = 'http://localhost:11434'

      ALLOWED_REQUEST_OPTIONS = %i[timeout open_timeout read_timeout write_timeout].freeze

      DEFAULT_FARADAY_ADAPTER = :typhoeus

      def initialize(config)
        @server_sent_events = config.dig(:options, :server_sent_events)

        @address = if config[:credentials][:address].nil? || config[:credentials][:address].to_s.strip.empty?
                     "#{DEFAULT_ADDRESS}/"
                   else
                     "#{config[:credentials][:address].to_s.sub(%r{/$}, '')}/"
                   end

        @bearer_token = config[:credentials][:bearer_token]

        @basic_auth_username = nil
        @basic_auth_password = nil

        if config[:credentials].key?(:basic_auth) && config[:credentials][:basic_auth].is_a?(Hash)
          @basic_auth_username = config[:credentials][:basic_auth][:username] if config[:credentials][:basic_auth].key?(:username)
          @basic_auth_password = config[:credentials][:basic_auth][:password] if config[:credentials][:basic_auth].key?(:password)
        elsif config[:credentials].key?(:basic_auth) && config[:credentials][:basic_auth].is_a?(String)
          @basic_auth_username, @basic_auth_password = config[:credentials][:basic_auth].to_s.split(':')
        end

        @request_options = config.dig(:options, :connection, :request)

        @request_options = if @request_options.is_a?(Hash)
                             @request_options.select do |key, _|
                               ALLOWED_REQUEST_OPTIONS.include?(key)
                             end
                           else
                             {}
                           end

        @faraday_adapter = config.dig(:options, :connection, :adapter) || DEFAULT_FARADAY_ADAPTER
      end

      def generate(payload, server_sent_events: nil, &callback)
        request('api/generate', payload, server_sent_events:, &callback)
      end

      def chat(payload, server_sent_events: nil, &callback)
        request('api/chat', payload, server_sent_events:, &callback)
      end

      def create(payload, server_sent_events: nil, &callback)
        request('api/create', payload, server_sent_events:, &callback)
      end

      def tags(server_sent_events: nil, &callback)
        request('api/tags', nil, server_sent_events:, request_method: 'GET', &callback)
      end

      def show(payload, server_sent_events: nil, &callback)
        request('api/show', payload, server_sent_events:, &callback)
      end

      def copy(payload, server_sent_events: nil, &callback)
        request('api/copy', payload, server_sent_events:, &callback)
        true
      end

      def delete(payload, server_sent_events: nil, &callback)
        request('api/delete', payload, server_sent_events:, request_method: 'DELETE', &callback)
        true
      end

      def pull(payload, server_sent_events: nil, &callback)
        request('api/pull', payload, server_sent_events:, &callback)
      end

      def push(payload, server_sent_events: nil, &callback)
        request('api/push', payload, server_sent_events:, &callback)
      end

      def embeddings(payload, server_sent_events: nil, &callback)
        request('api/embeddings', payload, server_sent_events:, &callback)
      end

      def request(path, payload = nil, server_sent_events: nil, request_method: 'POST', &callback)
        server_sent_events_enabled = server_sent_events.nil? ? @server_sent_events : server_sent_events
        url = "#{@address}#{path}"

        if !callback.nil? && !server_sent_events_enabled
          raise Errors::BlockWithoutServerSentEventsError,
                'You are trying to use a block without Server Sent Events (SSE) enabled.'
        end

        results = []

        method_to_call = request_method.to_s.strip.downcase.to_sym

        partial_json = String.new.force_encoding('UTF-8')

        response = Faraday.new(request: @request_options) do |faraday|
          faraday.adapter @faraday_adapter
          faraday.response :raise_error
          faraday.request :authorization, 'Bearer', @bearer_token if @bearer_token
          if @basic_auth_username && @basic_auth_password
            faraday.request :authorization, :basic, @basic_auth_username, @basic_auth_password
          end
        end.send(method_to_call) do |request|
          request.url url
          request.headers['Content-Type'] = 'application/json'

          request.body = payload.to_json unless payload.nil?

          if server_sent_events_enabled
            request.options.on_data = proc do |chunk, bytes, env|
              if env && env.status != 200
                raise_error = Faraday::Response::RaiseError.new
                raise_error.on_complete(env.merge(body: chunk))
              end

              utf8_chunk = chunk.force_encoding('UTF-8')

              partial_json += if utf8_chunk.valid_encoding?
                                utf8_chunk
                              else
                                utf8_chunk.encode('UTF-8', invalid: :replace, undef: :replace)
                              end

              parsed_json = safe_parse_json(partial_json)

              if parsed_json
                result = { event: parsed_json, raw: { chunk:, bytes:, env: } }

                callback.call(result[:event], result[:raw]) unless callback.nil?

                results << result

                partial_json = String.new.force_encoding('UTF-8')
              end
            end
          end
        end

        return safe_parse_jsonl(response.body) unless server_sent_events_enabled

        results.map { |result| result[:event] }
      rescue Faraday::Error => e
        raise Errors::RequestError.new(e.message, request: e, payload:)
      end

      def safe_parse_json(raw)
        raw.to_s.lstrip.start_with?('{', '[') ? JSON.parse(raw) : nil
      rescue JSON::ParserError
        nil
      end

      def safe_parse_jsonl(raw)
        raw.to_s.lstrip.start_with?('{', '[') ? raw.split("\n").map { |line| JSON.parse(line) } : raw
      rescue JSON::ParserError
        raw
      end
    end
  end
end
