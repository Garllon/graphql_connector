# frozen_string_literal: true

module GraphqlConnector
  module ServiceClassable
    class ReturnFieldsErrors < StandardError; end
    # Valdations for return fields set within the context of a service class
    class ReturnFieldsValidator
      class << self
        def validate(return_fields)
          unless return_fields.is_a?(Array)
            raise ReturnFieldsErrors, 'Please ensure that returns is followed '\
                                      'by an array. E.g. returns: [:id]'
          end

          return_fields.each { |entry| recursive_validation(entry) }
        end

        private

        def recursive_validation(entry)
          case entry
          when Hash
            hash_validation(entry)
          when Array
            entry.each { |item| recursive_validation(item) }
          else
            return if [String, Symbol].member?(entry.class)

            raise ReturnFieldsErrors, "The #{entry} is neither a String nor a"\
                                      'Symbol!'
          end
        end

        def hash_validation(hash)
          hash.each do |key, value|
            recursive_validation(key)
            recursive_validation(value)
          end
        end
      end
    end
  end
end
