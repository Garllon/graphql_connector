
# GraphqlConnector

[![Gem
Version](https://badge.fury.io/rb/graphql_connector.svg)](https://badge.fury.io/rb/graphql_connector)
[![CI](https://github.com/Garllon/graphql_connector/workflows/CI/badge.svg)](https://github.com/Garllon/graphql_connector/actions?query=workflow%3ACI)
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
  config.add_server(name: 'Foo', uri: 'http://foo.com/api/graphql', headers: {}, connector: {})
end
```

The connector is expecting that it contains a `base` connector instance and a
`method` parameter as string, where it gets the token. WE expect that the
method is a public method in your connector class. Currently like this:
```ruby
{ base: TokenAgent.new, method: 'get_authorization_header' }
```

Your method should return a hash like this:
```ruby
class TokenAgent
   [...]
   def get_authorization_header
      [...]
      { 'Authorization' => 'Token HERE' }
   end
end
```

When you set a connector, it will override the setting in the headers for
Authorization.

For each graphql server you wish to query use `add_server`.

Afterwards you will have the following options to fetch and/or mutate data with
one or many graphql servers:

* `raw_query` --> [Examples](examples/raw_query_examples.rb)
* `query` --> [Examples](examples/query_examples.rb)
* `mutation` --> [Examples](examples/mutation_examples.rb)
* `service class inclusion` --> [Examples](examples/departments_service_class_examples.rb)

See the following sub sections for details

### raw_query

You can call your graphql_endpoint via:
```ruby
GraphqlConnector::<name>.raw_query(query_string)
```

Note that `<name>` has to be replaced by any of the ones added via `add_server`

See also [here](examples/raw_query_examples.rb) for example usage

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

See also [here](examples/query_examples.rb) for example usage

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

### mutation

Works in the same way as [query](#query)

See also [here](examples/mutation_examples.rb) for example usage

### Service class inclusion

This approach can be used to `graphqlize` **any** kind of ruby (service) class
so that it has re-usable graphql `query` and `mutation` **class methods**.

* First add `extend GraphqlConnector::<server>::Query` in the the class(es) that should be `graphqlized`

* Then you can aliases as many graphql server types via `add_query` and/or `add_raw_query` and/or `add_mutation`:

```ruby
add_query <alias>: :<graphql_server_type>, params: [...], returns: [...]

add_raw_query <alias>: 'query { ... }', params: [...]

add_mutation <alias>: :<graphql_server_type>, params: [...], returns: [...]
```
* :grey_exclamation: If not needed omit `params`

See also [here](examples/departments_service_class_examples.rb) and also here for complete example usage:

```ruby
GraphqlConnector.configure do |config|
  config.add_server(name: 'Foo', uri: 'http://foo.com/api/graphql', headers: {})
end

# product.rb
class Product
  extend GraphqlConnector::Foo::Query

  add_query all: :products,
            returns: [:id, :name]

  add_query by_id: :products,
            params: :id,
            returns: [:name, product_category: [:id, :name]]

  add_query by_names: :products,
            params: :names,
            returns: [:id, :name, product_category: [:id, :name]]

  add_query by: :products,
            params: [:id, :name],
            returns: [:name]

  add_query by_category_id: :products,
            params: :product_category,
            returns: [product_category: [:id, :name]]

  add_mutation create: :createProduct,
               params: [:name, :catgetoryId],
               returns: [:id, :name]
end

Product.all
=> [OpenStruct<id=1, name='Demo Product', ...]

Product.by_id(id: 1)
=> [OpenStruct<name='Demo Product', product_category=<ProductCategory<id=10, name='Demo Category'>>]

Product.by_names(names: ['Demo Product', 'Non Demo Product'])
=> [OpenStruct<id=1, name='Demo Product', product_category=<ProductCategory<id=10, name='Demo Category'>>, Product<id=2, name='Demo Product' ...]

Product.by(id: 1, name: 'Demo Product')
=> OpenStruct<name='Demo Product'>

Product.by_category_id(product_category: { id: 10})
=> OpenStruct<product_category=<ProductCategory<id=10, name='Demo Category'>>

Product.create(name: 'Another Product', catgetoryId: 10)
=> OpenStruct<id=10, name='Another Product'>
```

Also custom **class methods** can used to call any kind of `query` and do further selection instead:

```ruby
class Product
  extend GraphqlConnector::Foo::Query

  add_query all: :products, returns: [:name]

  def self.by_id(id:)
    all.select { |products| products.id == id }.first
  end
end

Product.by_id(id: 1)
=> OpenStruct<id=1, name='Demo Product'>>
```

:warning: Ensure that your custom **class method** never has the **same name** as an `<alias>` of `add_query`, `add_raw_query` or `add_mutation`. Otherwise the associated grapqhl query will not be performed because of [Ruby Open Class principle](https://ruby-lang.co/ruby-open-class/)


Example for `raw_query`:

```ruby
class Product
  extend GraphqlConnector::Foo::Query

  add_raw_query all: ' query { products { id name } } '
  add_raw_query by: ' query products($id: !ID, $name: !String) '\
                '{ products(id: $id, name: $name) { id name } }',
                params: [:id, :name]

end

Product.all
=> [ { id: '1', name: 'Demo Product' }, ...]

Product.by(id: '1', name: 'Demo Product')
=> { id: '1', name: 'Demo Product' }

```

:exclamation: There is no `add_raw_mutation` since `add_raw_query` does already cover such a case

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
