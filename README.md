[![Gem Version](https://badge.fury.io/rb/csv_fast_importer.svg)](https://badge.fury.io/rb/csv_fast_importer) ![Tests status](https://github.com/github/docs/actions/workflows/tests.yml/badge.svg) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/1ecd555b2ff3414d92bc8674b29c68ea)](https://www.codacy.com/gh/sogilis/csv_fast_importer/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sogilis/csv_fast_importer&amp;utm_campaign=Badge_Grade)


# CSV Fast Importer

A gem to import CSV files' content into a PostgreSQL or MySQL database. It is respectively based on [PostgreSQL `COPY`](https://wiki.postgresql.org/wiki/COPY) and [MySQL `LOAD DATA INFILE`](https://dev.mysql.com/doc/refman/5.7/en/load-data.html) which are designed to be as fast as possible.

## Why?

CSV importation is a common task which can be done by more than 6 different gems, but none of them is able to import **1 million of lines in a few seconds** (see benchmark below), hence the creation of this gem.

Here is an indicative benchmark to compare available solutions. It represents the **duration (ms)** to import a **10 000 lines** csv file into a local PostgreSQL instance on a laptop running OSX (lower is better):

![Benchmark](benchmark/results.png?raw=true "Benchmark")

Like all benchmarks, some tuning can produce different results, yet this chart gives a big picture. See [benchmark details](benchmark/README.md).

## Requirements

- Rails (ActiveRecord in fact)
- PostgreSQL or MySQL

## Limitations

- Usual ActiveRecord process (validations, callbacks, computed fields like `created_at`...) is bypassed. This is the price for performance
- Custom enclosing field (ex: `"`) is not supported yet
- Custom line separator (ex: `\r\n` for windows file) is not supported yet
- MySQL: encoding is not supported yet
- MySQL: transaction is not supported yet
- MySQL: row_index is not supported yet

Note about custom line separator: it might work by opening the file with the `universal_newline` argument (e.g. `file = File.new(path, universal_newline: true)`). Unfortunately, we weren't able to reproduce and test it so we don't support it "officialy". You can find more information in [this ticket](https://github.com/sogilis/csv_fast_importer/pull/45#issuecomment-326578839) (in French).

## Installation

Add the dependency to your Gemfile:

```ruby
gem 'csv_fast_importer'
```

Run `bundle install`.

You can install the gem by yourself too:

```sh
$ gem install csv_fast_importer
```

**For MySQL** :warning: enable `local_infile` for both [client](https://dev.mysql.com/doc/refman/5.7/en/source-configuration-options.html#option_cmake_enabled_local_infile) and [server](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_local_infile). In Rails application, juste add `local_infile: true` to your database config file `databse.yml` to configure the database client. See [Security Issues with LOAD DATA LOCAL](https://dev.mysql.com/doc/refman/5.7/en/load-data-local.html) for more details.


## Usage

Actually, CSV Fast Importer needs `active_record` to work. Setup your database
configuration as in a usual Rails project. Then, use the `CsvFastImporter`
class:

```ruby
require 'csv_fast_importer'

file = File.new '/path/to/knights.csv'
imported_lines_count = CsvFastImporter.import(file)

puts imported_lines_count
```

Under the hood, CSV Fast Importer deletes data from the `knights` table and
imports those from `knights.csv` by mapping columns' names to table's fields.
Note: mapping is case insensitive so **database fields' names must be lowercase**.
For instance, a `FIRSTNAME` CSV column will be mapped to the `firstname` field.

### Options

| Option key | Purpose | Default value |
| ------------ | ------------- | ------------- |
| *encoding* | File encoding. *PostgreSQL only* (see [FAQ](doc/faq.md) for more details)| `'UTF-8'` |
| *col_sep* | Column separator in file | `';'` |
| *destination* | Destination table | given base filename (without extension) |
| *mapping* | Column mapping | `{}` |
| *row_index_column* | Column name where inserting file row index (not used when `nil`). *PostgreSQL only* | `nil` |
| *transaction* | Execute DELETE and INSERT in same transaction. *PostgreSQL only* | `:enabled` |
| *deletion* | Row deletion method (`:delete` for SQL DELETE, `:truncate` for SQL TRUNCATE or `:none` for no deletion before import) | `:delete` |

If your CSV file is not encoded with same table than your database, you can specify encoding at the file opening (see [FAQ](doc/faq.md) for more details):

```ruby
file = File.new '/path/to/knights.csv', encoding: 'ISO-8859-1'
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
CsvFastImporter.import file, mapping: { knight_email: :email }
```

## Need help?

See [FAQ](doc/faq.md).

## How to contribute?

You can fork and submit new pull request (with tests and explanations).
First of all, you need to initialize your environment :

```sh
$ brew install postgresql # in macOS
$ apt-get install libpq-dev # in Linux
$ bundle install
```

Then, start your PostgreSQL database (ex: [Postgres.app](http://postgresapp.com) for the Mac) and setup database environment:

```sh
$ bundle exec rake test:db:create
```
This will connect to `localhost` PostgreSQL database without user (see `config/database.postgres.yml`) and create a new database dedicated to tests.

*Warning:* database instance have to allow database creation with `UTF-8` encoding.

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

## Backlog (unordered)

- [ ] Support any column and table case
- [ ] Support custom enclosing field (ex: `"`)
- [ ] Support custom line serparator (ex: \r\n for windows file)
- [ ] Support custom type convertion
- [ ] MySQL: support encoding parameter. See https://dev.mysql.com/doc/refman/5.5/en/charset-charsets.html
- [ ] MySQL: support transaction parameter
- [ ] MySQL: support row_index_column parameter
- [ ] MySQL: run multiple SQL queries in single statement
- [ ] Refactor tests (with should-> must / should -> expect / subject...)
- [ ] Reduce technical debt on db connection (test & benchmark)
- [ ] SQLite support

## How to release new version?

Make sure your are in `master` branch. Then, run:
```bash
bundle exec rake release:make[major|minor|patch|x.y.z]
```

Example: `bundle exec rake release:make[minor]`
