# -----------------------------------------------------------------------------
# All tested strategy (implementations).
# -----------------------------------------------------------------------------

# CSVFastImporter -------------------------------------------------------------
def csv_fast_importer(file)
  CsvFastImporter.import file, col_sep: ','
end

# CSV.foreach + ActiveRecord .create! -----------------------------------------
def csv_foreach_and_create(file)
  require 'csv'
  Dataset.transaction do
    CSV.foreach(file, headers: true) do |row|
      Dataset.create!(row.to_hash)
    end
  end
end

# SmarterCSV + ActiveRecord .create! ------------------------------------------
def smarter_csv_and_create(file)
  require 'smarter_csv'
  Dataset.transaction do
    SmarterCSV.process(file.path, chunk_size: 1000) do |dataset_attributes|
      Dataset.create! dataset_attributes
    end
  end
end

# SmarterCSV + activerecord-import --------------------------------------------
def smarter_csv_and_activerecord_import(file)
  require 'smarter_csv'
  require 'activerecord-import/base'
  SmarterCSV.process(file.path, chunk_size: 1000) do |dataset_attributes|
    datasets = dataset_attributes.map { |attributes| Dataset.new attributes }
    Dataset.import dataset_attributes.first.keys, datasets, batch_size: 100, validate: false
  end
end

# SmarterCSV + BulkInsert -----------------------------------------------------
def smarter_csv_and_bulk_insert(file)
  require 'smarter_csv'
  require 'bulk_insert'
  SmarterCSV.process(file.path, chunk_size: 1000) do |dataset_attributes|
    Dataset.bulk_insert values: dataset_attributes
  end
  # Nearly same performance with following code:
  # Dataset.bulk_insert(set_size: 500) do |worker|
  #   SmarterCSV.process(file.path, chunk_size: 500) do |dataset_attributes|
  #     dataset_attributes.each do |attributes|
  #       worker.add attributes
  #     end
  #   end
  # end
end

# CSV.foreach + Upsert --------------------------------------------------------
def csv_foreach_and_upsert(file)
  require 'csv'
  require 'upsert'
  Upsert.logger.level = Logger::ERROR
  Upsert.batch(Dataset.connection, Dataset.table_name) do |upsert|
    CSV.foreach(file, headers: true) do |row|
      upsert.row(row.to_hash)
    end
  end
end


# CSVImporter -----------------------------------------------------------------
require 'csv-importer'
class DatasetCSVImporter
  include CSVImporter

  model Dataset
end

def csv_importer(file)
  DatasetCSVImporter.new(path: file.path).run!
end

# ActiveImporter --------------------------------------------------------------
require 'active_importer'
class DatasetActiveImporter < ActiveImporter::Base
  imports Dataset
end

# ActiveImporter --------------------------------------------------------------
def active_importer(file)
  DatasetActiveImporter.import file.path
end

# ferry -----------------------------------------------------------------------
def ferry(file)
  # Required to make ferry work without a rails application
  require 'yaml'
  FileUtils.mkdir_p('config') unless File.exists?('config')
  config_file = 'config/database.yml'
  FileUtils.touch(config_file)
  config = YAML.load(<<-EOT)
    benchmark_env:
      adapter: postgresql
      database: csv_fast_importer_test
    EOT
  File.open(config_file, 'w') { |f| f.write config.to_yaml }

  # Prevent progress output
  $stderr.reopen(Tempfile.new('benchmark_ferry').path, "w")

  require 'ferry'
  Ferry::Importer.new.import_csv "benchmark_env", "datasets", file.path

  FileUtils.rm(config_file)
end

