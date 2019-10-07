# frozen_string_literal: true

module GraphqlConnector
  class QueryBuilder
    def initialize(model, conditions, selected_fields)
      @model            = model
      @conditions       = conditions
      @selected_fields  = selected_fields
    end

    def create
      "query { #{@model}(#{main_filter}) { #{parse_fields(@selected_fields)} } }"
    end

    private

    def main_filter
      conditions = @conditions.each_with_object([]) do |(key, value), array|
        next if value.is_a? Hash # will be processed in #field_with_filter

        array << "#{key}: #{value_as_parameter(value)}"
      end

      conditions.join(', ')
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

    def handle_association(hash)
      hash.map do |key, fields|
        "#{key} { #{parse_fields(fields)} }"
      end
    end
  end
end
