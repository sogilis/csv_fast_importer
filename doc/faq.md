# Frequently Asked Questions

## How to specify encoding?

Multiple componants are involved when `CSV Fast Importer` is executed:

- file
- ruby `File` wrapper
- database client (managed by `ActiveRecord` connection)
- SQL command (`COPY` for PostgreSQL)
- database server

Encoding may be consistent accross all these componants. Here is how to specify or check each componant encoding.

### File

You can get current file encoding with `file -i [file_path]` (`-I` on macOS) command.
Some tools like [iconv](http://www.gnu.org/savannah-checkouts/gnu/libiconv/documentation/libiconv-1.15/iconv.1.html) can modify file encoding.

### Ruby `File` wrapper

`File` uses default Ruby encoding (given by `Encoding.default_external`. See [External / Internal Encoding](https://ruby-doc.org/core-2.4.1/Encoding.html#class-Encoding-label-External+encoding) which might be different from file enoding!

```ruby
File.new 'path/to/file.csv'
```

But, you can specify encoding with `encoding` parameter:

```ruby
File.new 'path/to/file.csv', encoding: 'ISO-8859-1'
```

Ruby `File` can also handle internal and external encoding (see [File::new](https://ruby-doc.org/core-2.4.1/File.html#method-c-new) which can be useful to manage automatic conversion:

```ruby
File.new 'path/to/file.csv', external_encoding: 'ISO-8859-1', internal_encoding: 'UTF-8'
# or
File.new 'path/to/file.csv', encoding: 'ISO-8859-1:UTF-8'
```

### Database client

Database is accessed through a dedicated client.
This client is managed by `ActiveRecord` with some configuration (`database.yml` in Rails application) where `encoding` parameter can be defined.

### SQL Command

By default, `COPY` and `LOAD DATA INFILE` commands follow database client encoding configuration. But you can override this with dedicated parameter.
This is the purpose of `CSV FAST Importer`'s `encoding` parameter.

### Database server

Each Postgres server instance is encoded with a specific table. You can show this with following command:

```shell
psql -l
```

Or, from `psql` client:

```sql
\l
```
