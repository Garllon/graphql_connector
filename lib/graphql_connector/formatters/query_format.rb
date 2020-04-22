# frozen_string_literal: true

module GraphqlConnector
  module Formatters
    # Class that returns in query string format
    class QueryFormat
      include SelectedFields

      def initialize(model, conditions, selected_fields)
        @model = model
        @conditions = conditions
        @selected_fields = selected_fields
      end

      def create
        <<-STRING
        query {
          #{@model}#{arguments} {
            #{parse_fields(@selected_fields)}
          }
        }
        STRING
      end

      private

      def arguments
        conditions = @conditions.each_with_object([]) do |(key, value), array|
          next if value.is_a? Hash # will be processed in #field_with_filter

          array << "#{key}: #{value_as_parameter(value)}"
        end

        "(#{conditions.join(', ')})"
      end

      def value_as_parameter(value)
        case value
        when TrueClass, FalseClass, Integer, Float
          value
        when Array
          casted_values = value.map { |v| value_as_parameter(v) }
          "[#{casted_values.join(',')}]"
        else # fallback to string
          '"' + value.to_s + '"'
        end
      end
    end
  end
end
