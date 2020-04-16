# frozen_string_literal: true

module GraphqlConnector
  module ServiceClassable
    class InvalidClassMethodError < StandardError; end
    # Checks whether a class method for a specific graphql query is in an
    # expected format
    class ClassMethodValidator
      class << self
        def validate(class_method_name, query_type)
          return if [String, Symbol].member?(class_method_name.class) &&
                    [String, Symbol].member?(query_type.class)

          raise InvalidClassMethodError,
                "Please ensure that #{class_method_name} #{query_type} has "\
                'the following format => <method_alias>: ' \
                '<graphql query or type> (e.g. all: :all_products)'
        end
      end
    end
  end
end
