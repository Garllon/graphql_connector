# frozen_string_literal: true

module GraphqlConnector
  # Wrapper class for HTTParty post query
  class HttpClient
    def initialize(uri, headers)
      @uri = uri
      @headers = headers
    end

    def query(model, conditions, selected_fields)
      query_string = GraphqlConnector::QueryBuilder.new(model,
                                                        conditions,
                                                        selected_fields).create
      parsed_body = raw_query(query_string)
      result = parsed_body['data'][model]
      return OpenStruct.new(result) unless result.is_a? Array

      result.map { |entry| OpenStruct.new(entry) }
    end

    def raw_query(query_string)
      response = HTTParty.post(@uri,
                               headers: @headers,
                               body: { query: query_string })
      parsed_body = JSON.parse(response.body)
      verify_response!(parsed_body)
      parsed_body
    end

    private

    def verify_response!(parsed_body)
      return unless parsed_body.key? 'errors'

      raise CustomAttributeError, parsed_body['errors']
    end
  end
end
