# frozen_string_literal: true

module GraphqlConnector
  module ServiceClassable
    # Module that allows to build query methods within the context of
    # service class
    module Queryable
      CONDITIONS = 'binding.local_variables.map do |var|
                      [var, binding.local_variable_get(var)]
                    end.to_h'

      def add_query(params: [], httparty_adapter_options: {}, returns:, **method_to_query)
        class_method_name = method_to_query.first[0]
        query_type = method_to_query.first[1]
        ensure_params_format!(returns, class_method_name, query_type)

        if params.empty?
          return query_method(class_method_name, query_type, returns, httparty_adapter_options)
        end

        ParamsValidator.validate(params)
        query_keyword_method(class_method_name,
                             query_type, params, returns, httparty_adapter_options)
      end

      def add_raw_query(params: [], httparty_adapter_options: {}, **method_to_raw_query)
        class_method_name = method_to_raw_query.first[0]
        query_string = method_to_raw_query.first[1]
        ClassMethodValidator.validate_class_method(class_method_name, self)
        ClassMethodValidator.validate_element_class_type(query_string, String)

        if params.empty?
          return raw_query_method(class_method_name, query_string, httparty_adapter_options)
        end

        ParamsValidator.validate(params)
        raw_query_keyword_method(class_method_name, query_string, params, httparty_adapter_options)
      end

      def add_mutation(params: [], httparty_adapter_options: {}, returns:, **method_to_query)
        class_method_name = method_to_query.first[0]
        query_type = method_to_query.first[1]
        ensure_params_format!(returns, class_method_name, query_type)

        if params.empty?
          return mutation_method(class_method_name, query_type, returns, httparty_adapter_options)
        end

        ParamsValidator.validate(params)
        mutation_keyword_method(class_method_name,
                                query_type, params, returns, httparty_adapter_options)
      end

      private

      def ensure_params_format!(returns, class_method_name, query_type)
        ReturnFieldsValidator.validate(returns)
        ClassMethodValidator.validate_class_method(class_method_name, self)
        ClassMethodValidator.validate_element_class_type(query_type, Symbol)
      end

      def query_method(class_method_name, query_type, return_fields, httparty_adapter_options)
        define_singleton_method class_method_name do
          http_client.query(query_type,
                            {},
                            return_fields.to_a,
                            httparty_adapter_options: httparty_adapter_options)
        end
      end

      def raw_query_method(class_method_name, query_string, httparty_adapter_options)
        define_singleton_method class_method_name do
          http_client.raw_query(query_string, httparty_adapter_options: httparty_adapter_options)
        end
      end

      def query_keyword_method(name, query_type, keywords, return_fields, httparty_adapter_options)
        keywords = [keywords].flatten
        instance_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{name}(#{keywords.map { |keyword| "#{keyword}:" }.join(', ')})
            http_client.query("#{query_type}",
                              #{CONDITIONS},
                              #{return_fields.to_a},
                              httparty_adapter_options: #{httparty_adapter_options})
          end
        METHOD
      end

      def raw_query_keyword_method(name, query_string, keywords, httparty_adapter_options)
        keywords = [keywords].flatten
        instance_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{name}(#{keywords.map { |keyword| "#{keyword}:" }.join(', ')})
            http_client.raw_query("#{query_string}",
                                  variables: #{CONDITIONS},
                                  httparty_adapter_options: #{httparty_adapter_options})
          end
        METHOD
      end

      def mutation_method(class_method_name, query_type, return_fields, httparty_adapter_options)
        define_singleton_method class_method_name do
          http_client.mutation(query_type, {}, return_fields.to_a, httparty_adapter_options)
        end
      end

      def mutation_keyword_method(name,
                                  query_type, keywords, return_fields, httparty_adapter_options)
        keywords = [keywords].flatten
        instance_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{name}(#{keywords.map { |keyword| "#{keyword}:" }.join(', ')})
            http_client.mutation("#{query_type}",
                                  #{CONDITIONS},
                                  #{return_fields.to_a},
                                  httparty_adapter_options: #{httparty_adapter_options})
          end
        METHOD
      end
    end
  end
end
