# frozen_string_literal: true

module GraphqlConnector
  module ServiceClassable
    # Module that allows to build query methods within the context of
    # service class
    module Queryable
      BINDINGS = 'binding.local_variables.map do |var|
                    [var, binding.local_variable_get(var)]
                  end.to_h'

      def add_query(params: [], httparty_adapter_options: {}, returns:, **method_to_query)
        class_method_name, query_type = parse_variables(method_to_query)

        ensure_params_format!(returns, class_method_name, query_type)
        ParamsValidator.validate(params) unless params.empty?

        signature = method_signature(class_method_name, params)
        signature[:graphql_method_type] = :query
        create_method(signature, query_type, returns, httparty_adapter_options)
      end

      def add_raw_query(params: [], httparty_adapter_options: {}, **method_to_raw_query)
        class_method_name, query_string = parse_variables(method_to_raw_query)

        ClassMethodValidator.validate_class_method(class_method_name, self)
        ClassMethodValidator.validate_element_class_type(query_string, String)
        ParamsValidator.validate(params) unless params.empty?

        signature = method_signature(class_method_name, params)
        raw_query_method(signature, query_string, httparty_adapter_options)
      end

      def add_mutation(params: [], httparty_adapter_options: {}, returns:, **method_to_query)
        class_method_name, query_type = parse_variables(method_to_query)

        ensure_params_format!(returns, class_method_name, query_type)
        ParamsValidator.validate(params) unless params.empty?

        signature = method_signature(class_method_name, params)
        signature[:graphql_method_type] = :mutation
        create_method(signature, query_type, returns, httparty_adapter_options)
      end

      private

      def parse_variables(method_to_query)
        class_method_name = method_to_query.first[0]
        query_type        = method_to_query.first[1]
        [class_method_name, query_type]
      end

      def method_signature(name, keywords)
        return { head: name, bindings: {} } if keywords.empty?

        keywords = [keywords].flatten
        { head: "#{name}(#{keywords.map { |keyword| "#{keyword}:" }.join(', ')})",
          bindings: BINDINGS }
      end

      def ensure_params_format!(returns, class_method_name, query_type)
        ReturnFieldsValidator.validate(returns)
        ClassMethodValidator.validate_class_method(class_method_name, self)
        ClassMethodValidator.validate_element_class_type(query_type, Symbol)
      end

      def raw_query_method(signature, query_string, httparty_adapter_options)
        instance_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{signature[:head]}
            http_client.raw_query("#{query_string}",
                                  variables: #{signature[:bindings]},
                                  httparty_adapter_options: #{httparty_adapter_options})
          end
        METHOD
      end

      def create_method(signature, query_type, return_fields, httparty_adapter_options)
        instance_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{signature[:head]}
            http_client.#{signature[:graphql_method_type]}(
              "#{query_type}",
              #{signature[:bindings]},
              #{return_fields.to_a},
              httparty_adapter_options: #{httparty_adapter_options})
          end
        METHOD
      end
    end
  end
end
