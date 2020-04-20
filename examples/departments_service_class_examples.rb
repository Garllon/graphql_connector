# frozen_string_literal: true

uri = 'http://rails-graphql-server.herokuapp.com/api/graphql'
GraphqlConnector.configure do |config|
  config.add_server(name: 'RailsGraphqlServer', uri: uri, headers: {})
end

# Service class for fetching department data
class Department
  extend GraphqlConnector::RailsGraphqlServer::Query

  add_query all: :departments, returns: [:id, :name, employees: [:yearlySalary]]

  add_query by_id: :departments,
            params: [:id],
            returns: [:id, :name, employees: [:yearlySalary]]

  add_raw_query all_raw: 'query {
                            departments {
                              id name employees { yearlySalary }
                            }
                          }'

  add_raw_query by_id_raw: 'query departments($id: [ID!]) {
                              departments(id: $id) {
                                name employees { name }
                              }
                            }',
                params: [:id]
end

Department.all

Department.by_id(id: %w[1 2])

Department.all_raw

Department.by_id_raw(id: %w[1 2])
