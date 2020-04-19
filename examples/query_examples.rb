# frozen_string_literal: true

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
