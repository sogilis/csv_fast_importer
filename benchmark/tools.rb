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

# Downloaded from http://ouvert.canada.ca/data/fr/dataset
ORIGINAL_DATASET_FILE = File.new('benchmark/NPRI-SubsDisp-Normalized-Since1993.csv')

def build_dataset(db, file_name, lines_count)
  puts "Database schema generation..."
  db.execute "DROP TABLE IF EXISTS #{file_name}"
  db.execute <<-SQL
    CREATE TABLE #{file_name} (
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

  dataset_file = File.new("benchmark/#{file_name}.csv", 'w+')
  `head -n #{lines_count} #{ORIGINAL_DATASET_FILE.path} > #{dataset_file.path}`
  yield dataset_file
  File.delete(dataset_file)
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
  File.open(File::NULL, "w") do |file|
    $stdout = file
    yield
    $stdout = original_stdout
  end
end
