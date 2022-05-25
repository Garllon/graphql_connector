## 2.0.0 (TBD)

### Features

Write here

### Breaking changes

* query results are now transformed to OpenStructs recursively, so nested attributes are no longer a hash but another OpenStruct
* snake_case names in non-raw queries are translated to camelCase and camelCase names in responses to snake_case. This way you are able to stay all snake_case in your Ruby code. You can disable this translation with the new server flags `camelize_query_names` and `underscore_response_names`.

## 1.4.0 (2022-03-17)

* Add config for `httparty_adapter_options` allowing forwarding options to `httparty`

## 1.3.1 (2021-06-04)

* add more specs to test headers and connectors
* make the headers option optinal
* update the readme to explain the connector functionality better

## 1.3.0 (2021-06-02)

* add the option to use a connector instead of init header for authorization
  part of headers 

## 1.2.1 (2021-05-25)

* relax httparty dependency(`~> 0.17` => `~> 0.16`)

## 1.2.0 (2020-12-22)

### Features
* Add `mutation` under server namespace and service class inclusion
* See `README` for details

## 1.1.1 (2020-5-04)

### BugFix
* Omit invalid `()` for empty conditions in `query` method

## 1.1.0 (2020-4-19)

### Features
* Allow building graphql querying in custom classes via `service class inclusion`
* See `README` for details about `service class inclusion`

### BugFix
* Forward `variables` when performing a `raw_query`

## 1.0.0 (2020-1-26)

### Breaking
* add multiple graphql server querying
* `query` and `raw_query` nested under server namespace


## 0.2.0 (2019-11-19)

### Features
* new `raw_query` method. you have to write the graphql query
  string by your self and also you get only the parsed json back.
* query supports associations for the selected_fields attribute

## 0.1.0.beta1 (2019-10-06)

### BugFix
* use model instead of hardcoded product


## 0.1.0.beta (2019-10-03)

* easy graphql logic
