# frozen_string_literal: true

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# ! The following examples are used together with
# ! https://github.com/sushie1984/rails-graphql-server
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GraphqlConnector.configure do |config|
  config.add_server(name: 'RailsGraphqlServer',
                    uri: 'http://rails-graphql-server.herokuapp.com/api/graphql',
                    headers: {})
end

GraphqlConnector::RailsGraphqlServer.raw_query(
  'query { departments { id name employees { yearlySalary } } }'
)

GraphqlConnector::RailsGraphqlServer.raw_query(
  'query departments($id: [ID!]) {
    departments(id: $id) { name employees { name }
    }
  }',
  variables: { id: %w[1 2] }
)
