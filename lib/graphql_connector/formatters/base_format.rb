# frozen_string_literal: true

module GraphqlConnector
  module Formatters
    # Class that returns in query or mutation string format
    class BaseFormat
      def initialize(model, conditions, selected_fields, camelize_query_names)
        @model = model
        @conditions = conditions
        @selected_fields = selected_fields
        @camelize_query_names = camelize_query_names
      end

      def create
        <<-STRING
        #{query_type} {
          #{camelize(@model)}#{arguments} {
            #{parse_fields(@selected_fields)}
          }
        }
        STRING
      end

      private

      def arguments
        conditions = @conditions.each_with_object([]) do |(key, value), array|
          array << "#{camelize(key)}: #{value_as_parameter(value)}"
        end

        return '' if conditions.empty?

        "(#{conditions.join(', ')})"
      end

      def value_as_parameter(value)
        case value
        when Array
          casted_values = value.map { |v| value_as_parameter(v) }
          "[#{casted_values.join(',')}]"
        when Hash
          casted_values = value.map { |k, v| "#{camelize(k)}: #{value_as_parameter(v)}" }
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

      def parse_fields(selected_fields)
        results = selected_fields.map do |field|
          case field
          when Hash
            handle_association(field)
          else
            camelize(field)
          end
        end

        results.join(' ')
      end

      def handle_association(hash)
        hash.map do |key, fields|
          "#{camelize(key)} { #{parse_fields(fields)} }"
        end
      end

      def camelize(word)
        return word unless @camelize_query_names

        word.to_s.gsub(/_([a-z\d])/) do
          Regexp.last_match(1).upcase
        end
      end

      def query_type
        raise 'query_type undefined'
      end
    end
  end
end
