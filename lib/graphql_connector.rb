# frozen_string_literal: true

require 'graphql_connector/version'
require 'graphql_connector/configuration'

module GraphqlConnector
  class Error < StandardError; end
  # Your code goes here...
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
