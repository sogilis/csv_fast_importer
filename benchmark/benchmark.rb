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

    puts "Run CsvFastImporter..."
    csv_fast_importer_time = time { CsvFastImporter.import file }
    native_active_record_create_time = native_active_record_create(file)

    puts ""
    puts "Results:"
    puts "CsvFastImporter: #{csv_fast_importer_time}s"
    puts "Native ActiveRecord #create!: #{native_active_record_create_time}s"
    puts ""
    puts "Benchmark finished."
  end

  def self.time
    start_time = Time.now
    yield
    Time.now - start_time
  end

  def self.native_active_record_create(file)
    csv = CSV.parse(File.read(file), headers: true, col_sep: ';')
    time do
      csv.each do |row|
        Knight.create!(row.to_hash)
      end
    end
  end
end
