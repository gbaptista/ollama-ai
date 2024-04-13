# frozen_string_literal: true

require_relative '../../ports/dsl/ollama-ai'

client = Ollama.new(
  credentials: { address: 'http://localhost:11434' },
  options: { server_sent_events: true }
)

puts client.show({ name: 'yi:latest' })[0]['license']
