# frozen_string_literal: true

require 'graphql_connector/version'
require 'graphql_connector/query_builder'
require 'graphql_connector/configuration'
require 'graphql_connector/custom_attribute_error'
require 'httparty'

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
    response = HTTParty.post(GraphqlConnector.configuration.host,
                             headers: GraphqlConnector.configuration.headers,
                             body: { query: query_string })
    parsed_body = JSON.parse(response.body)
    OpenStruct.new(parsed_body['data'][model])
  end
end
