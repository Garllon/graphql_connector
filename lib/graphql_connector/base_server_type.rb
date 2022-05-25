# frozen_string_literal: true

module GraphqlConnector
  class BaseServerTypeAlreadyExistsError < StandardError; end
  # Class to wrap http_client calls under a specific namespaced class
  class BaseServerType
    class << self
      def build(name, uri, headers = {}, connector = {}, httparty_adapter_options = {},
                camelize_query_names = true, underscore_response_names = true)
        verify_new_client_type_for!(name)
        base_class = class_with(uri, headers, connector, httparty_adapter_options,
                                camelize_query_names, underscore_response_names)
        base_object = GraphqlConnector.const_set(name, base_class)
        inject_http_client_delegations(base_object)
        create_service_class_module(base_object)

        base_object
      end

      private

      def verify_new_client_type_for!(name)
        return unless GraphqlConnector.const_defined?(name)

        raise BaseServerTypeAlreadyExistsError,
              "The name: #{name} is already in use. Check your "\
              'configuration!'
      end

      def create_service_class_module(base_object)
        base_object.class_eval <<-METHOD, __FILE__, __LINE__ + 1
          module Query
            def self.extended(base)
              base.extend(GraphqlConnector::ServiceClassable::Queryable)
            end

            def http_client
              #{base_object}.http_client
            end
          end
        METHOD
      end

      def class_with(uri, headers = {}, connector = {}, httparty_adapter_options = {},
                     camelize_query_names = true, underscore_response_names = true)
        Class.new do
          attr_accessor :uri, :headers, :connector, :httparty_adapter_options,
                        :camelize_query_names, :underscore_response_names
          @uri       = uri
          @headers   = headers
          @connector = connector
          @httparty_adapter_options = httparty_adapter_options
          @camelize_query_names = camelize_query_names
          @underscore_response_names = underscore_response_names
        end
      end

      def inject_http_client_delegations(base_object)
        base_object.instance_eval do
          extend SingleForwardable
          def_delegators :http_client, :query, :raw_query, :mutation

          def http_client
            @http_client ||= GraphqlConnector::HttpClient.new(@uri, @headers, @connector,
                                                              @httparty_adapter_options,
                                                              @camelize_query_names,
                                                              @underscore_response_names)
          end
        end
      end
    end
  end
end
