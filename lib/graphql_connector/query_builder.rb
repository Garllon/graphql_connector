# frozen_string_literal: true

module GraphqlConnector
  # create the graphql query_string out of the given attributes.
  class QueryBuilder
    def initialize(type, model, inputs, selected_fields)
      @type             = type
      @model            = model
      @inputs           = inputs
      @selected_fields  = selected_fields
    end

    def create
      <<-STRING
      #{@type} {
        #{@model}#{main_filter} {
          #{parse_fields(@selected_fields)}
        }
      }
      STRING
    end

    private

    def main_filter
      conditions = @inputs.each_with_object([]) do |(key, value), array|
        array << "#{key}: #{value_as_parameter(value)}"
      end

      return @model if conditions.empty?

      "#{@model}(#{conditions.join(', ')})"
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
