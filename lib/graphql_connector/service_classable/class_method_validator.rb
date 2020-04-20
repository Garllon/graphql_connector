# frozen_string_literal: true

module GraphqlConnector
  module ServiceClassable
    class ClassMethodAlreadyImplementedError < StandardError; end
    class InvalidClassTypeError < StandardError; end
    # Checks whether a class method for a specific graphql query is in an
    # expected format
    class ClassMethodValidator
      class << self
        def validate_class_method(class_method_name, invoked_class)
          return unless invoked_class.singleton_methods
                                     .map(&:to_s)
                                     .include?(class_method_name.to_s)

          error_msg = "The (raw_)add_query '#{class_method_name}: ... ' is "\
                      'already implemented within the context of '\
                      "#{invoked_class} and therefore cannot be used!"
          raise ClassMethodAlreadyImplementedError, error_msg
        end

        def validate_element_class_type(element, class_types)
          return if element.class == class_types

          raise InvalidClassTypeError, "Please ensure that #{element} is a"\
                                       "#{class_types}!"
        end
      end
    end
  end
end
