# frozen_string_literal: true

require 'graphql_connector/version'
require 'graphql_connector/query_builder'
require 'graphql_connector/configuration'
require 'graphql_connector/http_client'
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
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.query(model, conditions, selected_fields)
    query_string = QueryBuilder.new(model, conditions, selected_fields).create
    parsed_body = raw_query(query_string)
    OpenStruct.new(parsed_body['data'][model])
  end

  def self.raw_query(query_string)
    response = HTTParty.post(GraphqlConnector.configuration.host,
                             headers: GraphqlConnector.configuration.headers,
                             body: { query: query_string })
    parsed_body = JSON.parse(response.body)

    if parsed_body.key? 'errors'
      raise CustomAttributeError, parsed_body['errors']
    end

    parsed_body
  end
end
