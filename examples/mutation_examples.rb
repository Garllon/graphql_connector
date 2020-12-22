# frozen_string_literal: true

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# ! The following examples are used together with
# ! https://github.com/sushie1984/rails-graphql-server
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

uri = 'http://rails-graphql-server.herokuapp.com/api/graphql'
GraphqlConnector.configure do |config|
  config.add_server(name: 'RailsGraphqlServer', uri: uri, headers: {})
end

department_input = { attributes: { name: 'One', location: 'Berlin' } }
return_fields = ['department': ['id', 'name', 'employees' => ['yearlySalary']]]
GraphqlConnector::RailsGraphqlServer.mutation('createDepartment',
                                              { input: department_input },
                                              return_fields)
