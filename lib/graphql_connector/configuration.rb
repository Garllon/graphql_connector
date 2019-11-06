# frozen_string_literal: true

module GraphqlConnector
  # The configuration template file for the gem.
  class Configuration
    attr_accessor :host, :headers

    def initialize
      @host = nil
      @headers = nil
    end
  end
end
