# frozen_string_literal: true

module GraphqlConnector
  # Wrapper class for HTTParty post query
  class HttpClient
    def initialize(uri, headers = {}, connector = {}, httparty_adapter_options = {})
      @uri = uri
      @headers = headers
      @connector = connector
      @httparty_adapter_options = httparty_adapter_options
    end

    def query(model, conditions, selected_fields, httparty_adapter_options: {})
      query_string = Formatters::QueryFormat.new(model, conditions, selected_fields).create
      format_body(query_string, model, httparty_adapter_options)
    end

    def mutation(model, inputs, selected_fields, httparty_adapter_options: {})
      query_string = Formatters::MutationFormat.new(model, inputs, selected_fields).create
      format_body(query_string, model, httparty_adapter_options)
    end

    def raw_query(query_string, variables: {}, httparty_adapter_options: {})
      adapter_options = combined_adapter_options(httparty_adapter_options)
      response = HTTParty.post(@uri,
                               headers: handle_headers,
                               body: { query: query_string, variables: variables },
                               **adapter_options)
      parsed_body = JSON.parse(response.body)
      verify_response!(parsed_body)
      parsed_body
    end

    private

    def combined_adapter_options(options)
      @httparty_adapter_options.merge(options)
    end

    def handle_headers
      return @headers if @connector.empty?

      @headers
        .merge(@connector[:base].public_send(@connector[:method]))
    end

    def format_body(query_string, model, httparty_adapter_options)
      parsed_body   = raw_query(query_string, httparty_adapter_options: httparty_adapter_options)
      response_body = parsed_body['data'][model.to_s]
      transform_data(response_body)
    end

    def transform_data(data)
      case data
      when Array
        data.map { |element| transform_data(element) }
      when Hash
        transform_hash(data)
      else
        data
      end
    end

    def transform_hash(original_hash)
      transformed_hash = original_hash.each_with_object({}) do |(key, value), hash|
        hash[underscore(key)] = transform_data(value)
      end
      OpenStruct.new(transformed_hash)
    end

    def underscore(word)
      word
        .gsub(/([A-Z]+)(?=[A-Z][a-z])|([a-z\d])(?=[A-Z])/) do
          (Regexp.last_match(1) || Regexp.last_match(2)) << '_'
        end
        .tr('-', '_')
        .downcase
    end

    def verify_response!(parsed_body)
      return unless parsed_body.key? 'errors'

      raise CustomAttributeError, parsed_body['errors']
    end
  end
end
