# frozen_string_literal: true

module GraphqlConnector
  module ServiceClassable
    class InvalidParamsError < StandardError; end
    # Checks whether params for a specifc graphql query are in an expected
    # format
    class ParamsValidator
      class << self
        def validate(query_params)
          params = [query_params].flatten
          return if params.empty? ||
                    params.map(&:class).uniq == [Symbol] ||
                    params.map(&:class).uniq == [String]

          raise InvalidParamsError,
                "Please ensure that #{query_params} are either "\
                'Symbols/Strings as described in the README '\
                '(e.g.: params: [:id, :name])'
        end
      end
    end
  end
end
