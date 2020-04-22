# frozen_string_literal: true

module GraphqlConnector
  module Formatters
    # Helper class that returns selected fields for query/mutation
    module SelectedFields
      def parse_fields(selected_fields)
        results = selected_fields.map do |field|
          case field
          when Hash
            handle_association(field)
          else
            field
          end
        end

        results.join(' ')
      end

      private

      def handle_association(hash)
        hash.map do |key, fields|
          "#{key} { #{parse_fields(fields)} }"
        end
      end
    end
  end
end
