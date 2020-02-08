
# GraphqlConnector

[![Gem
Version](https://badge.fury.io/rb/graphql_connector.svg)](https://badge.fury.io/rb/graphql_connector)
[![Build
Status](https://travis-ci.org/Garllon/graphql_connector.svg?branch=master)](https://travis-ci.org/Garllon/graphql_connector)
[![Maintainability](https://api.codeclimate.com/v1/badges/548db3cf0d078b379c84/maintainability)](https://codeclimate.com/github/Garllon/graphql_connector/maintainability)

An easy connector to call your `graphql` server. Currently there is no schema
check in the code, but i will add it.

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
  config.add_server(name: 'Foo', uri: 'http://foo.com/api/graphql', headers: {})
end
```

For each graphql server you wish to query use `add_server`.

Afterwards you will have the following options to fetch and/or mutate data with
one or many graphql servers:

* `raw_query`
* `query`
* `service class inclusion`

See the following sub sections for details

### raw_query

You can call your graphql_endpoint via:
```ruby
GraphqlConnector::<name>.raw_query(query_string)
```

Note that `<name>` has to be replaced by any of the ones added via `add_server`

---
### query

You can also use the more comfortable `query`:
```ruby
GraphqlConnector::<name>.query(model, condition, selected_fields)
```

| Variable        | DataType                | Example                                 |
|----------------|-------------------------|------------------------------------------|
| model           | String                  | 'product'                               |
| condition       | Hash(key, value)        | { id: 1 }                               |
| selected_fields | Array of Strings/Hashes | ['id', 'name', productCategory: ['id']] |

> Caution:
> You get an OpenStruct back. Currently only the first level attributes are
> supported with OpenStruct, associated objects are still a normal array of
> hashes.

#### selected_fields

The syntax for the associations looks like the following:
```
['<attribute_name>', <association_name>: ['<attribute_name_of_the_association>']]
```

Example:
```ruby
['id', 'name', productCategory: ['id', 'name']]
```

---

### Service class inclusion

This approach can be used to `graphqlize` **any** kind of ruby (service) class
so that it has re-usable graphql query methods.

* First add `extend GraphqlConnector::<server>::Query` in the the class
* Add a `return_fields` which defines what fields are going to be returned
* Next for each mapping add a `query` that alias the type that the server supports as follows
  * `query <alias>: <query type in graphql server>, params: [<any kind of query type params>]`
  * If query type does not need them, omit `params`

Examples:

```ruby
GraphqlConnector.configure do |config|
  config.add_server(name: 'Foo', uri: 'http://foo.com/api/graphql', headers: {})
end

# product.rb
class Product
  extend GraphqlConnector::Foo::Query
  return_fields :id, :name, product_category: [:id, :name]

  query all: :products_all
  query by_id: :products_all, params: :id
  query by_names: :product_all, params: :names
  query by: :product_all, params: [:id, :name]
  query by_category_id: :product_all, params: :product_category
end

Product.all
=> [OpenStruct<id=1, name='Demo Product', product_category=<ProductCategory<id=10, name='Demo Category'>>, ...]

Product.by_id(id: 1)
=> OpenStruct<id=1, name='Demo Product', product_category=<ProductCategory<id=10, name='Demo Category'>>

Product.by_names(names: ['Demo Product', 'Non Demo Product'])
=> [OpenStruct<id=1, name='Demo Product', product_category=<ProductCategory<id=10, name='Demo Category'>>, Product<id=2, name='Demo Product' ...]

Product.by(id: 1, name: 'Demo Product')
=> OpenStruct<id=1, name='Demo Product'>

Product.by_category_id(product_category: { id: 10})
=> OpenStruct<id=1, name='Demo Product', product_category=<ProductCategory<id=10, name='Demo Category'>>
```

Also custom **class methods** can used to call any kind of `query` and do further selection instead:

```ruby
class Product
  include GraphqlConnector::Foo::Query
  return_fields :id, :name, product_category: [:id, :name]

  query all: :products_all

  def self.by_id(id:)
    all.select { |products| products.id == id }.first
  end
end

Product.by_id(id: 1)
=> OpenStruct<id=1, name='Demo Product', product_category=<ProductCategory<id=10, name='Demo Category'>>
```

Last but not least raw queries can also be used, like the following:

```ruby
class Product
  include GraphqlConnector::Foo::Query
  return_fields :id, :name, product_category: [:id, :name]

  query all: ' query { products { id name } } '
  query by: ' query { products($id: !ID, $name: !String) '\
            '{ products(id: $id, name: $name) { id name } } } ',
             params: [:id, :name]

end

Product.all
=> [ { id: '1', name: 'Demo Product', ...]

Product.by(id: '1', name: 'Demo Product')
=> { id: '1', name: 'Demo Product' }

```

## Development

After checking out the repo, run
```shell
bundle install
```

Then, run
```shell
bundle exec rspec spec
```
to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/garllon/graphql_connector](https://github.com/garllon/graphql_connector). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GraphqlConnector project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Garllon/graphql_connector/blob/master/CODE_OF_CONDUCT.md).
