require 'active_record'
require_relative './tools'

class Dataset < ActiveRecord::Base
end

require_relative './strategies'

db = database_connect
file = prepare_dataset(db)
lines_count = count(file)
puts "Start benchmark with a #{lines_count} lines file."

puts "Running benchmark..."
{
  'CsvFastImporter' => :csv_fast_importer,
  'CSV.foreach + ActiveRecord .create' => :csv_foreach_and_create,
  'SmarterCSV + ActiveRecord .create' => :smarter_csv_and_create,
  'SmarterCSV + activerecord-import' => :smarter_csv_and_activerecord_import,
  'SmarterCSV + bulk_insert' => :smarter_csv_and_bulk_insert,
  'CSV.foreach + upsert' => :csv_foreach_and_upsert,
  'CSVImporter' => :csv_importer,
  'ActiveImporter' => :active_importer,
  'Ferry' => :ferry
}.each do |strategy_label, method|
  db.execute 'TRUNCATE TABLE datasets'
  printf "%-50s: ", strategy_label

  duration = measure_duration { send(method, file) }

  warning_message = '(file partially imported)' if Dataset.count < lines_count - 1 # Header
  printf "%20d ms %s\n", duration, warning_message
end

puts
puts "Benchmark finished."
