# GraphqlConnector

[![Gem
Version](https://badge.fury.io/rb/graphql_connector.svg)](https://badge.fury.io/rb/graphql_connector)
[![Build
Status](https://travis-ci.org/Garllon/graphql_connector.svg?branch=master)](https://travis-ci.org/Garllon/graphql_connector)

An easy connector to call your `graphql` server. 
Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/graphql_connector`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql_connector'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphql_connector

## Usage

You need to configure the `graphql_connector` first:
``` ruby
GraphqlConnector.configure do |config|
  config.host = ''
  config.headers = {}
end
```

Then you can call your graphql_endpoint:
```ruby
GraphqlConnector.query(model, condition, selected_fields)
```

| Variable        | DataType         | Example        |
| ----------------|------------------| ---------------|
| model           | String           | 'product'      |
| condition       | Hash(key, value) | { id: 1 }      |
| selected_fields | Array of Strings | ['id', 'name'] |

## Development

After checking out the repo, run
```shell
bundle install
```

Then, run
```bundle exec rspec spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/garllon/graphql_connector. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GraphqlConnector project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/graphql_connector/blob/master/CODE_OF_CONDUCT.md).
