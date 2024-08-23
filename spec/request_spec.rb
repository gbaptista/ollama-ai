require 'spec_helper'
require_relative '../ports/dsl/ollama-ai'

RSpec.describe Ollama do
  let(:messages) { [{ role: "user", content: "What is the meaning of life?"}] }

  let(:request_body) {
    {
      model: "phi",
      system: "You are a helpful assistant.",
      messages: messages
    }  
  }

  let(:stubs) {
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post("http://localhost:11434/api/chat", request_body.to_json, { "Content-Type" => "application/json" }) do |env|
      [
        200,
        { "Content-Type" => "application/json; charset=utf-8" },
        { message: { content: "Forty two", role: "assistant" } }.to_json
      ]
    end
    stubs
  }

  let(:client) { 
    Ollama.new(
      credentials: { address: 'http://localhost:11434' }, 
      options: {
        server_sent_events: false,
        connection: {
          request: {
            timeout: 5,
            open_timeout: 6,
            read_timeout: 7,
            write_timeout: 8
          },
          adapter: [:test, stubs],
          # response: [:logger, ::Logger.new(STDOUT), bodies: true]
        }
      }
    ) 
  }

  describe '#chat' do
    it 'should respond with the correct message' do
      response = client.chat(request_body)
      expect(response.dig(0, "message", "content")).to eq("Forty two")
    end
  end

  describe '#faraday' do
    it 'should have the correct timeout' do
      expect(client.faraday.options.timeout).to eq(5)
    end

    it 'should have the correct open_timeout' do
      expect(client.faraday.options.open_timeout).to eq(6)
    end

    it 'should have the correct read_timeout' do
      expect(client.faraday.options.read_timeout).to eq(7)
    end

    it 'should have the correct write_timeout' do
      expect(client.faraday.options.write_timeout).to eq(8)
    end
  end
end
