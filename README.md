[![Build Status](https://travis-ci.org/sogilis/csv_fast_importer.svg?branch=master)](https://travis-ci.org/sogilis/csv_fast_importer) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/3747d356ba004b7da2d0aec6bf1160f0)](https://www.codacy.com/app/Jibidus/csv_fast_importer?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sogilis/csv_fast_importer&amp;utm_campaign=Badge_Grade)

# CSV Fast Importer

A gem to import CSV files' content into a PostgreSQL database. It is based on
the [Postgre `COPY` command](https://wiki.postgresql.org/wiki/COPY) which is
designed to be as faster as possible.

## Requirements

- Rails (ActiveRecord in fact)
- PostgreSQL or MySQL
- MySQL only: enable `local_infile` parameter (add `local_infile: true` to your database config file `databse.yml`)

## Limitations
- MySQL: encoding is not supported yet
- MySQL: transaction is not supported yet
- MySQL: row_index is not supported yet

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

file = File.new '/path/to/knights.csv'
imported_lines_number = CsvFastImporter.import file

puts imported_lines_number
```

Under the hood, CSV Fast Importer deletes data from the `knights` table and
imports those from `knights.csv` by mapping columns' names to table's fields.
Note: mapping is case insensitive so database fields' names must be lowercase.
For instance, a `FIRSTNAME` CSV column will be mapped to the `firstname` field.

### Options

| Option key | Purpose | Default value |
| ------------ | ------------- | ------------- |
| *encoding* | File encoding. PostgreSQL only| `'UTF-8'` |
| *col_sep* | Column separator in file | `';'` |
| *destination* | Destination table | given base filename (without extension) |
| *mapping* | Column mapping | `{}` |
| *row_index_column* | Column name where inserting file row index (not used when `nil`). PostgreSQL only | `nil` |
| *transaction* | Execute DELETE and INSERT in same transaction. PostgreSQL only | `:enabled` |
| *deletion* | Row deletion method (`:delete` for SQL DELETE, `:truncate` for SQL TRUNCATE or `:none` for no deletion before import) | `:delete` |

Your CSV file should be encoding in UTF-8 but you can specify another encoding
with the `encoding` option (PostgreSQL only).

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
`/path/to/knights.csv`, the table's name will be `knights`. To bypass
this default behaviour, specify the `destination` option:

```ruby
file = File.new '/path/to/clients.csv'
CsvFastImporter.import file, destination: 'knights'
```

Finally, you can precise a custom mapping between CSV file's columns and
database fields with the `mapping` option.

Considering the following `knights.csv` file:

```csv
NAME;KNIGHT_EMAIL
Perceval;perceval@logre.cel
Lancelot;lancelot@logre.cel
```

To map the `KNIGHT_EMAIL` column to the `email` database field:

```ruby
CsvFastImporter.import file, mapping: { email: :knight_email }
```

## How to contribute?

You can fork and submit new pull request (with tests and explanations).
First of all, you need to initialize your environment :

```sh
$ bundle install
```

Then, start your PostgreSQL database (ex: [Postgres.app](http://postgresapp.com) for the Mac) and setup database environment:

```sh
$ bundle exec rake test:db:create
```
This will connect to `localhost` PostgreSQL database without user (see `config/database.postgres.yml`) and create a new database dedicated to tests.

Finally, you can run all tests with RSpec like this:

```sh
$ bundle exec rspec
```

By default, PostgreSQL is used. You can set another database with environment variables like this for MySQL:
```sh
$ DB_TYPE=mysql DB_ROOT_PASSWORD=password DB_USERNAME=username bundle exec rake test:db:create
$ DB_TYPE=mysql DB_USERNAME=username bundle exec rspec
```
This will connect to mysql with `root` user (with `password` as password) and create database for user `username`.
Use `DB_TYPE=mysql DB_USERNAME=` (with empty username) for anonymous account.

*Warning*: Mysql tests require your local database permits LOCAL works. Check your Mysql instance with following command: `SHOW GLOBAL VARIABLES LIKE 'local_infile'` (should be `ON`).

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

## Roadmap

- [ ] Tests + README : change customer/kaamelott_test by knights
- [ ] Move classes in dedicated module (to prevent collisions in target application)
- [ ] Document supported database (#29)
- [ ] Code Review
- [ ] Publish gem (#30)
- [ ] MySQL: support encoding parameter. See https://dev.mysql.com/doc/refman/5.5/en/charset-charsets.html
- [ ] MySQL: support transaction parameter
- [ ] MySQL: support row_index_column parameter
- [ ] MySQL: Run multiple SQL queries in single statement
- [ ] Specify supported database versions (MySQL & PostgreSQL)
- [ ] Refactor tests (with should-> must / should -> expect / subject...)
