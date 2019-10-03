module GraphqlConnector
  class Configuration
    attr_accessor :host, :headers

    def initialize
      @host = nil
      @headers = nil
    end
  end
end
