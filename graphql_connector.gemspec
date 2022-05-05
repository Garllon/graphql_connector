# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql_connector/version'

Gem::Specification.new do |spec|
  spec.name          = 'graphql_connector'
  spec.version       = GraphqlConnector::VERSION
  spec.authors       = %w[Garllon sushie1984]
  spec.email         = ['palluthe.bennet@gmail.com', 'sascha_burku@yahoo.de']

  spec.summary       = 'GraphQL client'
  spec.description   = 'Grahql client to query with your own raw string, '\
                       'with the small helper method query or with service '\
                       'class inclusion.'
  spec.homepage      = 'https://github.com/Garllon/graphql_connector/blob/master/README.md'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Garllon/graphql_connector'
  spec.metadata['changelog_uri'] = 'https://github.com/Garllon/graphql_connector/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4.0'

  spec.add_dependency 'httparty', '~> 0.16'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rubocop', '~> 0.75'
  spec.add_development_dependency 'simplecov', '~> 0.21.2'
end
