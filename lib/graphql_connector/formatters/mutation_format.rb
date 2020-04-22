# frozen_string_literal: true

module GraphqlConnector
  module Formatters
    # Class that returns in mutation string format
    class MutationFormat
      include SelectedFields

      def initialize(model, inputs, selected_fields)
        @model = model
        @inputs = inputs
        @selected_fields = selected_fields
      end

      def create
        <<-STRING
        mutation {
          #{@model}#{arguments} {
            #{parse_fields(@selected_fields)}
          }
        }
        STRING
      end

      private

      def arguments
        inputs = @inputs.each_with_object([]) do |(key, value), array|
          array << "#{key}: #{value_as_parameter(value)}"
        end

        "(#{inputs.join(', ')})"
      end

      def value_as_parameter(value)
        case value
        when Array
          casted_values = value.map { |v| value_as_parameter(v) }
          "[#{casted_values.join(',')}]"
        when Hash
          casted_values = value.map { |k, v| "#{k}: #{value_as_parameter(v)}" }
          "{#{casted_values.join(',')}}"
        else
          scalar_types(value)
        end
      end

      def scalar_types(value)
        case value
        when TrueClass, FalseClass, Integer, Float
          value
        else # fallback to string
          '"' + value.to_s + '"'
        end
      end
    end
  end
end
