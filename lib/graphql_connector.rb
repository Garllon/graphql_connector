# frozen_string_literal: true

require 'graphql_connector/version'
require 'graphql_connector/formatters/base_format'
require 'graphql_connector/formatters/query_format'
require 'graphql_connector/formatters/mutation_format'
require 'graphql_connector/configuration'
require 'graphql_connector/http_client'
require 'graphql_connector/base_server_type'
require 'graphql_connector/service_classable/class_method_validator'
require 'graphql_connector/service_classable/params_validator'
require 'graphql_connector/service_classable/return_fields_validator'
require 'graphql_connector/service_classable/queryable'
require 'graphql_connector/custom_attribute_error'
require 'httparty'

# Main file of the GraphQLConnector
#   the main methods to configure the gem
#   and to run a raw_query or a normal query.
module GraphqlConnector
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration.reset!
  end

  def self.configure
    yield(configuration)
  end
end
