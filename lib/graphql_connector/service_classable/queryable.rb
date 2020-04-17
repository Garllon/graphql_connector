# frozen_string_literal: true

module GraphqlConnector
  module ServiceClassable
    # Module that allows to build query methods within the context of
    # service class
    module Queryable
      CONDITIONS = 'binding.local_variables.map do |var|
                      [var, binding.local_variable_get(var)]
                    end.to_h'

      def add_query(params: [], returns:, **build_params)
        class_method_name = build_params.first[0]
        query_type = build_params.first[1]
        ReturnFieldsValidator.validate(returns)
        ClassMethodValidator.validate(class_method_name, query_type)

        if params.empty?
          return query_method(class_method_name, query_type, returns)
        end

        ParamsValidator.validate(params)
        query_keyword_method(class_method_name, query_type, params, returns)
      end

      def add_raw_query(params: [], **build_params)
        class_method_name = build_params.first[0]
        query_string = build_params.first[1]
        ClassMethodValidator.validate(class_method_name, query_string)

        if params.empty?
          return raw_query_method(class_method_name, query_string)
        end

        ParamsValidator.validate(params)
        raw_query_keyword_method(class_method_name, query_string, params)
      end

      private

      def query_method(class_method_name, query_type, return_fields)
        define_singleton_method class_method_name do
          http_client.query(query_type, {}, return_fields.to_a)
        end
      end

      def raw_query_method(class_method_name, query_string)
        define_singleton_method class_method_name do
          http_client.raw_query(query_string)
        end
      end

      def query_keyword_method(name, query_type, keywords, return_fields)
        keywords = [keywords].flatten
        instance_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{name}(#{keywords.map { |keyword| "#{keyword}:" }.join(', ')})
            http_client.query("#{query_type}",
                              #{CONDITIONS},
                              #{return_fields.to_a})
          end
        METHOD
      end

      def raw_query_keyword_method(name, query_string, keywords)
        keywords = [keywords].flatten
        instance_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{name}(#{keywords.map { |keyword| "#{keyword}:" }.join(', ')})
            http_client.raw_query("#{query_string}", variables: #{CONDITIONS})
          end
        METHOD
      end
    end
  end
end
