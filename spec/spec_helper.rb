# frozen_string_literal: true

require 'bundler/setup'
Bundler.setup

require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
SimpleCov.start do
  add_filter 'spec'
end

require 'graphql_connector'

RSpec.configure do |config|
  config.warnings = true
  config.order = :random
end
