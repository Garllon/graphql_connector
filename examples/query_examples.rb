# frozen_string_literal: true

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# ! The following examples are used together with
# ! https://github.com/sushie1984/rails-graphql-server
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

uri = 'http://rails-graphql-server.herokuapp.com/api/graphql'
GraphqlConnector.configure do |config|
  config.add_server(name: 'RailsGraphqlServer', uri: uri, headers: {})
end

GraphqlConnector::RailsGraphqlServer.query('departments',
                                           {},
                                           ['id', 'name',
                                            'employees' => ['yearlySalary']])

GraphqlConnector::RailsGraphqlServer.query('departments',
                                           { id: %w[1 2] },
                                           ['id', 'name',
                                            'employees' => ['yearlySalary']])
