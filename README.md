[![Build Status](https://travis-ci.org/sogilis/csv_fast_importer.svg?branch=master)](https://travis-ci.org/sogilis/csv_fast_importer) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/3747d356ba004b7da2d0aec6bf1160f0)](https://www.codacy.com/app/Jibidus/csv_fast_importer?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sogilis/csv_fast_importer&amp;utm_campaign=Badge_Grade)

# CSV Fast Importer

A gem to import CSV files' content into a PostgreSQL database. It is based on
the [Postgre `COPY` command](https://wiki.postgresql.org/wiki/COPY) which is
designed to be as faster as possible.

## Requirements

- PostgreSQL
- Rails (ActiveRecord in fact)

## Installation

Add the dependency to your Gemfile and execute `bundle install`:

```gemfile
gem 'csv_fast_importer`
```

You can install the gem by yourself too:

```sh
$ gem install csv_fast_importer
```

## Usage

Actually, CSV Fast Importer needs `active_record` to work. Setup your database
configuration as in a usual Rails project. Then, use the `CsvFastImporter`
class:

```ruby
require 'csv_fast_importer'

file = File.new '/path/to/customers.csv'
imported_lines_number = CsvFastImporter.import file

puts imported_lines_number
```

Under the hood, CSV Fast Importer deletes data from the `customers` table and
imports those from `customers.csv` by mapping columns' names to table's fields.
Note: mapping is case insensitive so database fields' names must be lowercase.
For instance, a `FIRSTNAME` CSV column will be mapped to the `firstname` field.

### Options

| Option key | Purpose | Default value |
| ------------ | ------------- | ------------- |
| *encoding* | File encoding | `UTF-8` |
| *col_sep* | Column separator in file | `;` |
| *destination* | Destination table | given base filename (without extension) |
| *mapping* | Column mapping | `{}` |
| *row_index_column* | Column name where inserting file row index (not used when `nil`) | `nil` |

Your CSV file should be encoding in UTF-8 but you can specify another encoding
with the `encoding` option.

```ruby
CsvFastImporter.import file, encoding: 'ISO-8859-1'
```

You can specify a different separator column with the `col_sep` option (`;` by
default):

```ruby
CsvFastImporter.import file, col_sep: '|'
```

By default, CSV Fast Importer computes the database table's name by taking the
`basename` of the imported file. For instance, considering the imported file
`/path/to/customers.csv`, the table's name will be `customers`. To bypass
this default behaviour, specify the `destination` option:

```ruby
file = File.new '/path/to/clients.csv'
CsvFastImporter.import file, destination: 'customers'
```

Finally, you can precise a custom mapping between CSV file's columns and
database fields with the `mapping` option.

Considering the following `customers.csv` file:

```csv
FIRSTNAME;LASTNAME;CUSTOMER_EMAIL
John;Doe;john@doe.com
Jane;Doe;jane@doe.com
```

To map the `CUSTOMER_EMAIL` column to the `email` database field:

```ruby
CsvFastImporter.import file, mapping: { email: :customer_email }
```

## Running tests

If you want to contribute, you will need to run the test suite. First of all,
make sure to setup a PostgreSQL database by running the provided Rake task:

```sh
$ rake test:db:create
```

Then, running the test suite is as simple as:

```sh
$ rake test
```

## Versioning

`master` is the development branch and releases are published as tags.

**We're not ready for the production yet (version < 1.0) so use this gem with
precaution.**

We follow the [Semantic Versioning 2.0.0](http://semver.org/) for our gem
releases.

In few words:

> Given a version number MAJOR.MINOR.PATCH, increment the:
>
> 1. MAJOR version when you make incompatible API changes,
> 2. MINOR version when you add functionality in a backwards-compatible manner,
>    and
> 3. PATCH version when you make backwards-compatible bug fixes.

## To do

- [ ] Check dependencies licences
- [ ] Remove ActiveRecord dependency
- [ ] Code Review
- [ ] Find logo
- [ ] Fix code Codacy coverage
- [ ] Migrate to RSpec
- [ ] Use a factory library to write CSV files
