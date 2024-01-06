# frozen_string_literal: true

require_relative '../../static/gem'
require_relative '../../controllers/client'

module Ollama
  def self.new(...)
    Controllers::Client.new(...)
  end

  def self.version
    Ollama::GEM[:version]
  end
end
