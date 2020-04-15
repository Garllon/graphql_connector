# frozen_string_literal: true

module GraphqlConnector
  module ServiceClassable
    class InvalidTypeMappingError < StandardError; end
    class InvalidParamsErrors < StandardError; end
    class ReturnFieldsErrors < StandardError; end
    # Base module that is invoked in BaseServerType
    module Query
      def self.included(base)
        base.extend Queryable
      end

      # Module that allows to build query methods within the context of
      # service class
      module Queryable
        CONDITIONS = 'binding.local_variables.map do |var|
                        [var, binding.local_variable_get(var)]
                      end.to_h'

        def return_fields(*fields)
          @return_fields ||= Set.new
          @return_fields.merge(fields)
        end

        def query(**type_mapping)
          params = type_mapping.delete(:params) || {}
          method_name = type_mapping.first[0]
          query_type = type_mapping.first[1]
          raw_query = query_type.is_a?(String)
          validate!(type_mapping, params)

          if params.empty?
            return query_method(method_name, query_type, raw_query)
          end

          keyword_query_method(method_name, query_type, params, raw_query)
        end

        private

        def query_method(name, query_type, raw_query)
          define_singleton_method name do
            return http_client.raw_query(query_type) if raw_query

            http_client.query(query_type, {}, @return_fields.to_a)
          end
        end

        def keyword_query_method(name, query_type, params, raw_query)
          params = [params].flatten
          instance_eval <<-METHOD, __FILE__, __LINE__ + 1
            def #{name}(#{params.map { |keyword| "#{keyword}:" }.join(', ')})
              if #{raw_query}
                http_client
                  .raw_query("#{query_type}", variables: #{CONDITIONS})
              else
                http_client
                  .query("#{query_type}", #{CONDITIONS}, #{@return_fields.to_a})
              end
            end
          METHOD
        end

        def validate!(type_mapping, params)
          validate_mapping!(type_mapping)
          validate_params!(params) unless params.empty?
          validate_return_fields!
        end

        def validate_mapping!(type_mapping)
          return if type_mapping.size == 1 &&
                    type_mapping.first[0].is_a?(Symbol) &&
                    (type_mapping.first[1].is_a?(Symbol) ||
                    type_mapping.first[1].is_a?(String))

          raise InvalidTypeMappingError,
                "Please ensure that #{type_mapping} has the following format "\
                '=> <alias>: <graphql server type> (e.g. all: :all_products)'
        end

        def validate_params!(params)
          return if params.is_a?(Symbol) ||
                    params.map(&:class).uniq == [Symbol]

          raise InvalidParamsErrors,
                "Please ensure that #{params} is either a Symbol or an Array "\
                'of Symbols as described in the README'
        end

        def validate_return_fields!
          return if defined?(@return_fields) && !@return_fields.empty?

          raise ReturnFieldsErrors, 'No return_fields defined. Please consult '\
                                    'README'
        end
      end
    end
  end
end
