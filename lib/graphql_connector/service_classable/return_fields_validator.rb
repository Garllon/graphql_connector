# frozen_string_literal: true

module GraphqlConnector
  module ServiceClassable
    class ReturnFieldsErrors < StandardError; end
    # Valdations for return fields set within the context of a service class
    class ReturnFieldsValidator
      class << self
        def validate(return_fields)
          return if !return_fields.nil? && !return_fields.empty?

          raise ReturnFieldsErrors, 'No return_fields defined. Please consult '\
                                    'README'
        end
      end
    end
  end
end
