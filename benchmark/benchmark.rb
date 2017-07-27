require 'active_record'

class Knight < ActiveRecord::Base
end


module Benchmark

  TOTAL_ROW_COUNT = 1_000

  def self.run
    puts "Start benchmark with a #{TOTAL_ROW_COUNT} lines file."
    require_relative '../spec/config/test_database.rb'
    test_db = TestDatabase.new
    test_db.connect
    require 'csv_fast_importer'
    db = CsvFastImporter::DatabaseFactory.build

    db.execute 'DROP TABLE IF EXISTS knights'
    case test_db.type
      when :mysql
        db.execute 'CREATE TABLE knights ( name varchar(32) NOT NULL, sits_on_round_table varchar(32) NOT NULL )'
      when :postgres
        db.execute 'CREATE TABLE knights ( name varchar(32) NOT NULL, sits_on_round_table varchar(32) NOT NULL )'
      else
        raise "Unknown database type: #{test_db.type}"
    end

    # Public data: http://ouvert.canada.ca/data/fr/dataset/40e01423-7728-429c-ac9d-2954385ccdfb

    puts "CSV file generation..."
    require_relative '../spec/support/csv_writer'
    header = [ %w(name sits_on_round_table) ]
    rows = [*1..TOTAL_ROW_COUNT].map { %w(Karadoc, yes) }
    file = CSVWriter.new('knights.csv').create(header + rows)

    subjects = {
      'CsvFastImporter' => :csv_fast_importer,
      'CSV + native ActiveRecord #create!' => :csv_and_native_active_record_create,
      'smarted_csv + native ActiveRecord #create!' => :smarter_csv_and_csv_and_native_active_record_create
    }

    puts ""
    puts "Benchmarking..."
    subjects.each do |label, method|
      duration = time { send(method, file) }
      puts "#{label}: #{duration}s"
    end
    puts ""
    puts "Benchmark finished."
  end

  def self.time
    start_time = Time.now
    yield
    Time.now - start_time
  end

  def self.csv_fast_importer(file)
    CsvFastImporter.import file
  end

  def self.csv_and_native_active_record_create(file)
    csv = CSV.parse(File.read(file), headers: true, col_sep: ';')
    time do
      csv.each do |row|
        Knight.create!(row.to_hash)
      end
    end
  end

  # Variable : chunk size
  def self.smarter_csv_and_csv_and_native_active_record_create(file)
    require 'smarter_csv'
    SmarterCSV.process(file.path, chunk_size: 100, col_sep: ';') do |knights|
      Knight.create! knights
    end
  end
end
