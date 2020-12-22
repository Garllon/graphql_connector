# frozen_string_literal: true

module GraphqlConnector
  module Formatters
    # Class that returns in query string format
    class QueryFormat < BaseFormat
      private

      def query_type
        'query'
      end
    end
  end
end
