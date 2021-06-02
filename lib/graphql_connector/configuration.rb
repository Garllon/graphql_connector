# frozen_string_literal: true

module GraphqlConnector
  # The configuration template file for the gem.
  class Configuration
    attr_reader :base_server_types

    def initialize
      @base_server_types = {}
    end

    def add_server(name:, uri:, headers:, connector: {})
      @base_server_types[name] =
        BaseServerType.build(name, uri, headers, connector)
    end

    def reset!
      @base_server_types.keys.each do |name|
        GraphqlConnector.const_get(name).send :remove_const, 'Query'
        GraphqlConnector.send :remove_const, name
      end
      @base_server_types = {}
    end
  end
end
