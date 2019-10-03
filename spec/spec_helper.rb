require 'bundler/setup'
Bundler.setup

require 'graphql_connector'

RSpec.configure do |config|
  config.warnings = true
  config.order = :random
end
