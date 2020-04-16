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

        def query(build_params)
          class_method_name = build_params.first[0]
          query_type = build_params.first[1]
          params = build_params[:params] || build_params['params'] || []
          ReturnFieldsValidator.validate(@return_fields)
          ClassMethodValidator.validate(class_method_name, query_type)

          return query_method(class_method_name, query_type) if params.empty?

          ParamsValidator.validate(params)
          keyword_query_method(class_method_name, query_type, params)
        end

        private

        def query_method(name, query_type)
          define_singleton_method name do
            return http_client.raw_query(query_type) if query_type.is_a?(String)

            http_client.query(query_type, {}, @return_fields.to_a)
          end
        end

        def keyword_query_method(name, query_type, params)
          params = [params].flatten
          instance_eval <<-METHOD, __FILE__, __LINE__ + 1
            def #{name}(#{params.map { |keyword| "#{keyword}:" }.join(', ')})
              if #{query_type.is_a?(String)}
                http_client
                  .raw_query("#{query_type}", variables: #{CONDITIONS})
              else
                http_client
                  .query("#{query_type}", #{CONDITIONS}, #{@return_fields.to_a})
              end
            end
          METHOD
        end
      end
    end
  end
end
