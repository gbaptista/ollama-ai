# frozen_string_literal: true

module Ollama
  module Errors
    class OllamaError < StandardError
      def initialize(message = nil)
        super
      end
    end

    class BlockWithoutServerSentEventsError < OllamaError; end

    class RequestError < OllamaError
      attr_reader :request, :payload

      def initialize(message = nil, request: nil, payload: nil)
        @request = request
        @payload = payload

        super(message)
      end
    end
  end
end
