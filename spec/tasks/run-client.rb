# frozen_string_literal: true

require_relative '../../ports/dsl/ollama-ai'

begin
  client = Ollama.new(
    credentials: { address: 'http://invalid' },
    options: { server_sent_events: true }
  )

  client.generate({ model: 'phi', prompt: 'Hi!' })
rescue StandardError => e
  raise "Unexpected error: #{e.class}" unless e.instance_of?(Ollama::Errors::RequestError)
end

client = Ollama.new(
  credentials: { address: 'http://localhost:11434' },
  options: { server_sent_events: true }
)

result = client.generate(
  { model: 'phi',
    prompt: 'Hi!' }
) do |event, _raw|
  print event['response']
end

puts '-' * 20

puts result.map { |event| event['response'] }.join
