# frozen_string_literal: true

require 'bundler/setup'
Bundler.setup

require 'simplecov'
SimpleCov.start

require 'graphql_connector'

RSpec.configure do |config|
  config.warnings = true
  config.order = :random
end

