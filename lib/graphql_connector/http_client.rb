# frozen_string_literal: true

module GraphqlConnector
  # Wrapper class for HTTParty post query
  class HttpClient
    def initialize(uri, headers, connector = {})
      @uri = uri
      @headers = headers
      @connector = connector
    end

    def query(model, conditions, selected_fields)
      query_string =
        Formatters::QueryFormat.new(model, conditions, selected_fields).create
      parsed_body = raw_query(query_string)
      format_body(parsed_body['data'][model.to_s])
    end

    def mutation(model, inputs, selected_fields)
      query_string =
        Formatters::MutationFormat.new(model, inputs, selected_fields).create
      parsed_body = raw_query(query_string)
      format_body(parsed_body['data'][model.to_s])
    end

    def raw_query(query_string, variables: {})
      response = HTTParty.post(@uri,
                               headers: handle_headers,
                               body: { query: query_string,
                                       variables: variables })
      parsed_body = JSON.parse(response.body)
      verify_response!(parsed_body)
      parsed_body
    end

    private

    def handle_headers
      return @headers if @connector.empty?

      @headers
        .merge(@connector[:base].send(@connector[:method]))
    end

    def format_body(response_body)
      return OpenStruct.new(response_body) unless response_body.is_a? Array

      response_body.map { |entry| OpenStruct.new(entry) }
    end

    def verify_response!(parsed_body)
      return unless parsed_body.key? 'errors'

      raise CustomAttributeError, parsed_body['errors']
    end
  end
end
