# frozen_string_literal: true

module GraphqlConnector
  module Formatters
    # Class that returns in mutation string format
    class MutationFormat < BaseFormat
      private

      def query_type
        'mutation'
      end
    end
  end
end
