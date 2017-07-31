# -----------------------------------------------------------------------------
# Set of usefull methods
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

def count(file)
  `wc -l "#{file.path}"`.strip.split(' ')[0].to_i
end

# In milliseconds
def measure_duration
  start_time = Time.now
  block_stdout { yield }
  (1000 * (Time.now - start_time)).to_i
end

def block_stdout
  original_stdout = $stdout
  $stdout = File.open(File::NULL, "w")
  yield
  $stdout = original_stdout
end
