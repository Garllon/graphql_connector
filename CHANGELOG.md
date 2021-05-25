## Unreleased

* relax httparty dependency

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
