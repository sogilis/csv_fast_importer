require 'active_record'

# -----------------------------------------------------------------------------
# Prerequisites
# -----------------------------------------------------------------------------
class Dataset < ActiveRecord::Base
end

# Required by CsvImporter
require 'csv-importer'
class DatasetCSVImporter
  include CSVImporter

  model Dataset
end

# Required by ActiveImporter
require 'active_importer'
class DatasetActiveImporter < ActiveImporter::Base
  imports Dataset
end


# -----------------------------------------------------------------------------
# Utilities
# -----------------------------------------------------------------------------
def database_connect
  require_relative '../spec/config/test_database.rb'
  test_db = TestDatabase.new
  test_db.connect
  require 'csv_fast_importer'
  CsvFastImporter::DatabaseFactory.build
end

# datasets.csv was downloaded from http://ouvert.canada.ca/data/fr/dataset
# and truncated to 10 000 lines
# Original file name: NPRI-SubsDisp-Normalized-Since1993.csv
def prepare_dataset(db)
  puts "Database schema generation..."
  db.execute 'DROP TABLE IF EXISTS datasets'
  db.execute <<-SQL
    CREATE TABLE datasets (
      Reporting_Year smallint NULL,
      NPRI_ID integer NULL,
      Facility_Name varchar(255) NULL,
      Company_Name varchar(255) NULL,
      NAICS integer NULL,
      Province varchar(255) NULL,
      CAS_Number varchar(255) NULL,
      substance_name varchar(255) NULL,
      group_escaped varchar(255) NULL,
      Category varchar(255) NULL,
      Quantity decimal NULL,
      Units varchar(255) NULL,
      Estimation_Method varchar(255) NULL
    )
  SQL

  File.new('benchmark/datasets.csv')
end

def bench
  start_time = Time.now
  block_stdout { yield }
  Time.now - start_time
end

def block_stdout
  original_stdout = $stdout
  $stdout = File.open(File::NULL, "w")
  yield
  $stdout = original_stdout
end


# -----------------------------------------------------------------------------
# Strategies
# -----------------------------------------------------------------------------
def csv_fast_importer(file)
  CsvFastImporter.import file, col_sep: ','
end

def csv_foreach_plus_create(file)
  require 'csv'
  Dataset.transaction do
    CSV.foreach(file, headers: true) do |row|
      Dataset.create!(row.to_hash)
    end
  end
end

# Variable : CSV chunk size
def smarter_csv_and_csv_and_native_active_record_create(file)
  require 'smarter_csv'
  Dataset.transaction do
    SmarterCSV.process(file.path, chunk_size: 1000) do |dataset_attributes|
      Dataset.create! dataset_attributes
    end
  end
end

# Variable : CSV chunk size + INSERT chunk size
def smarter_csv_and_activerecord_import(file)
  require 'smarter_csv'
  require 'activerecord-import/base'
  SmarterCSV.process(file.path, chunk_size: 1000) do |dataset_attributes|
    datasets = dataset_attributes.map { |attributes| Dataset.new attributes }
    Dataset.import dataset_attributes.first.keys, datasets, batch_size: 10, validate: false
  end
end

# Variable : CSV chunk size + INSERT chunk size
def bulk_insert(file)
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

def upsert(file)
  require 'csv'
  require 'upsert'
  Upsert.logger.level = Logger::ERROR
  Upsert.batch(Dataset.connection, Dataset.table_name) do |upsert|
    CSV.foreach(file, headers: true) do |row|
      upsert.row(row.to_hash)
    end
  end
end

def csv_importer(file)
  DatasetCSVImporter.new(path: file.path).run!
end

def active_importer(file)
  DatasetActiveImporter.import file.path
end

def ferry(file)
  # Required to make ferry work without a rails application
  require 'yaml'
  FileUtils.mkdir_p('config') unless File.exists?('config')
  config_file = 'config/database.yml'
  FileUtils.touch(config_file)
  config = YAML.load(<<-EOT)
    environment:
      adapter: postgresql
      database: csv_fast_importer_test
    EOT
  File.open(config_file, 'w') { |f| f.write config.to_yaml }

  require 'ferry'
  importer = Ferry::Importer.new
  importer.import_csv "environment", "datasets", file.path

  FileUtils.rm(config_file)
end


# -----------------------------------------------------------------------------
# Benchmark process
# -----------------------------------------------------------------------------
db = database_connect
file = prepare_dataset(db)
line_count = `wc -l "#{file.path}"`.strip.split(' ')[0].to_i
puts "Start benchmark with a #{line_count} lines file."

strategies = {
  'CsvFastImporter' => :csv_fast_importer,
  'CSV.foreach + ActiveRecord .create' => :csv_foreach_plus_create,
  'SmarterCSV + ActiveRecord .create' => :smarter_csv_and_csv_and_native_active_record_create,
  'SmarterCSV + activerecord-import' => :smarter_csv_and_activerecord_import,
  'bulk_insert' => :bulk_insert,
  'CSV.foreach + upsert' => :upsert,
  'CSVImporter' => :csv_importer,
  'ActiveImporter' => :active_importer,
  'Ferry' => :ferry
}
# Following gem is not studied here because of lack of maintenance:
#   - active_record_importer
#   - ar_import

puts "Running benchmark..."
strategies.each do |strategy_label, method|
  db.execute 'TRUNCATE TABLE datasets'
  printf "%-50s: ", strategy_label

  duration = bench { send(method, file) }

  additionnal_info = '(file partially imported)' if Dataset.count < line_count - 1 # Header
  printf "%ss %s\n", duration, additionnal_info
end
puts
puts "Benchmark finished."
