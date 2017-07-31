# Benchmark

## Description

There are many ways to import CSV files in a database. Some are based on native ruby libraries, other on dedicated gems.
We tried here to build a big picture on all main strategies.

:point_right: If you think one is missing, do not hesitate to create an issue, or better, submit pull request.

## Modus operandi

With each identified strategy, a **10 000 lines** CSV file (`datasets.csv`) is imported in a **PostgreSQL** database.

:information_source: `datasets.csv` was built from [canadian open data](http://ouvert.canada.ca/data/fr/dataset), specially from file `NPRI-SubsDisp-Normalized-Since1993.csv` which was truncated to 10 000 lines.

:information_source: Duration measure includes file reading and database writing, after transaction commit.

## Strategies

`Dataset` is an ActiveRecord model.

`file` is the file to import.

### CSV.foreach + ActiveRecord .create

```ruby
  require 'csv'
  Dataset.transaction do
    CSV.foreach(file, headers: true) do |row|
      Dataset.create!(row.to_hash)
    end
  end
```

### [SmarterCSV](https://github.com/tilo/smarter_csv) + ActiveRecord .create

CSV file reading can be customized with chunk size (this may affect performance).

```ruby
  require 'smarter_csv'
  Dataset.transaction do
    SmarterCSV.process(file.path, chunk_size: 1000) do |dataset_attributes|
      Dataset.create! dataset_attributes
    end
  end
```

### [SmarterCSV](https://github.com/tilo/smarter_csv) + [activerecord-import](https://github.com/zdennis/activerecord-import)

`activerecord-import` becomes efficient when importing multiple rows in same time. But importing the whole CSV file is not a solution because of memory foot print :boom:. So, we read here the CSV file by batch. This is done with `SmarterCSV` which have a small effect on global performances (see results).

:information_source: Model validations are skipped here to improve performances even if no validation was defined.

```ruby
  require 'smarter_csv'
  require 'activerecord-import/base'
  SmarterCSV.process(file.path, chunk_size: 1000) do |dataset_attributes|
    datasets = dataset_attributes.map { |attributes| Dataset.new attributes }
    Dataset.import dataset_attributes.first.keys, datasets, batch_size: 100, validate: false
  end
```

### [SmarterCSV](https://github.com/tilo/smarter_csv) + [bulk_insert](https://github.com/jamis/bulk_insert)

Same constraints than `activerecord-import`: batch processing improves performances.

```ruby
  require 'smarter_csv'
  require 'bulk_insert'
  SmarterCSV.process(file.path, chunk_size: 1000) do |dataset_attributes|
    Dataset.bulk_insert values: dataset_attributes
  end
```

### CSV.foreach + [upsert](https://github.com/seamusabshere/upsert)

```ruby
  require 'csv'
  require 'upsert'
  Upsert.batch(Dataset.connection, Dataset.table_name) do |upsert|
    CSV.foreach(file, headers: true) do |row|
      upsert.row(row.to_hash)
    end
  end
```

### [CSVImporter](https://github.com/pcreux/csv-importer)

```ruby
  DatasetCSVImporter.new(path: file.path).run!
```

### [ActiveImporter](https://github.com/continuum/active_importer)

```ruby
  DatasetActiveImporter.import file.path
```

### [Ferry](https://github.com/cmu-is-projects/ferry)

:information_source: `Ferry` is more than juste a gem which import CSV files but is can also be used to do that.

```ruby
  require 'ferry'
  Ferry::Importer.new.import_csv "benchmark_env", "datasets", file.path
```

## Results

![Benchmark](result.png?raw=true "Benchmark")

Produced on a MacBookPro (OSX 10.12.6, i5 2.4GHz, 8Go RAM, Flash drive), with local PostgreSQL **9.6.1.0** instance.

:information_source: Results variability accros multiple executions is lower then 5%.

## Explanations

First of all, CSV reading took approximatively **400ms** with `CSV.foreach`, and **1000ms** with `SmarterCSV`.

We also can notice that all strategies based on Rails' `create!` are very slow. Indeed, this strategy execute each SQL `INSERT` in a dedicated statement, and all ActiveRecord process (validations, callbacks...) is also executed. This last point could be very usefull in a Rails application, but is the main drawback when you look for performance.

`upsert` could be more efficient with an id column in imported file (and a unique constraint in database schema), which is not the case here. To give some idea, duration would be divided by 2 :rocket: with such additional column.

## How to execute this benchmark?

- Start local PostgreSQL database
- Execute benchmark
```
bundle exec rake benchmark
```

