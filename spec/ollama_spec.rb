require 'spec_helper'
require_relative '../ports/dsl/ollama-ai'

RSpec.describe Ollama do
  let(:invalid_client) { Ollama.new(credentials: { address: 'http://invalid' }, options: { server_sent_events: true }) }
  let(:valid_client) { Ollama.new(credentials: { address: 'http://localhost:11434' }, options: { server_sent_events: true }) }

  describe '#generate' do
    context 'when using an invalid client' do
      it 'raises a request error' do
        expect {
          invalid_client.generate({ model: 'phi', prompt: 'Hi!' })
        }.to raise_error(Ollama::Errors::RequestError)
      end
    end

    context 'when using a valid client' do
      it 'generates a response with events' do
        response = []
        valid_client.generate({ model: 'phi', prompt: 'Please include the word hello in your response' }) do |event, _raw|
          response << event['response']
        end

        expect(response.join).to_not be_nil
        puts response.join # previous tests were printing results, this is a nice sanity check
      end
    end
  end

  describe '#show' do
    it 'returns the license information for the specified model' do
      # Mock the client method to return the expected response
      # expected_response = [{ 'license' => 'Apache License' }] # Replace 'MIT' with the expected license
      # allow(valid_client).to receive(:show).with(name: 'yi:latest').and_return(expected_response)

      result = valid_client.show({ name: 'yi:latest' })
      
      expect(result[0]['license']).to include('Apache License')
    end
  end
end