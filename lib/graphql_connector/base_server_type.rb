# frozen_string_literal: true

module GraphqlConnector
  class BaseServerTypeAlreadyExistsError < StandardError; end
  # Class to wrap http_client calls under a specific namespaced class
  class BaseServerType
    class << self
      def build(name, uri, headers)
        verify_new_client_type_for!(name)
        base_class = class_with(uri, headers)
        base_object = GraphqlConnector.const_set(name, base_class)
        inject_http_client(base_object)
        inject_query_methods(base_object)
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

      def class_with(uri, headers)
        Class.new do
          attr_accessor :uri, :headers
          @uri = uri
          @headers = headers
        end
      end

      def inject_http_client(base_object)
        base_object.instance_eval do
          def http_client
            @http_client ||= GraphqlConnector::HttpClient.new(@uri, @headers)
          end
        end
      end

      def inject_query_methods(base_object)
        base_object.instance_eval do
          def query(model, conditions, selected_fields)
            http_client.query(model, conditions, selected_fields)
          end

          def raw_query(query_string, variables: {})
            http_client.raw_query(query_string, variables: variables)
          end
        end
      end
    end
  end
end
