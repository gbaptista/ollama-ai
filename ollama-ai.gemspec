# frozen_string_literal: true

require_relative 'static/gem'

Gem::Specification.new do |spec|
  spec.name    = Ollama::GEM[:name]
  spec.version = Ollama::GEM[:version]
  spec.authors = [Ollama::GEM[:author]]

  spec.summary = Ollama::GEM[:summary]
  spec.description = Ollama::GEM[:description]

  spec.homepage = Ollama::GEM[:github]

  spec.license = Ollama::GEM[:license]

  spec.required_ruby_version = Gem::Requirement.new(">= #{Ollama::GEM[:ruby]}")

  spec.metadata['allowed_push_host'] = Ollama::GEM[:gem_server]

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = Ollama::GEM[:github]

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test|spec|features)/})
    end
  end

  spec.require_paths = ['ports/dsl']

  spec.add_dependency 'faraday', '~> 2.10'
  spec.add_dependency 'faraday-typhoeus', '~> 1.1'
  spec.add_dependency 'typhoeus', '~> 1.4', '>= 1.4.1'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
