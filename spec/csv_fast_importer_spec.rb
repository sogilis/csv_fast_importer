require 'csv_fast_importer'
require_relative 'support/test_helper'
require_relative 'support/csv_writer'

describe CsvFastImporter do
  include DatabaseHelper
  include_context 'knights table with columns row_index, id and name'

  describe 'with custom column separator' do
    before do
      file = write_file [ %w(name id), %w(Karadoc 10) ], col_sep: '|'
      CsvFastImporter.import file, col_sep: '|'
    end

    it 'a new line must be inserted' do
      row_count.should eql 1
    end

    it 'fields are correctly separated' do
      db.query('SELECT name FROM knights').to_s.should eql 'Karadoc'
    end
  end

  describe 'with custom file encoding', skip_mysql: true do
    before do
      file = write_file [ %w(name id), %w(trépassé 10) ], encoding: 'ISO-8859-1'
      CsvFastImporter.import file, encoding: 'ISO-8859-1'
    end

    it 'must import with correct encoding' do
      db.query('SELECT name FROM knights').to_s.should eql 'trépassé'
    end
  end

  describe 'with custom file table destination' do
    before do
      filepath = write_file [ %w(name id), %w(Karadoc 10) ]
      @file = File.new filepath
      CsvFastImporter.import @file, destination: 'knights'
    end

    it 'a new line must be inserted' do
      row_count.should eql 1
    end
  end

  describe 'without same column order between csv header and database table' do
    before do
      file = write_file [ %w(name id), %w(Karadoc 10) ]
      CsvFastImporter.import file
    end

    it 'a new line must be inserted' do
      row_count.should eql 1
    end

    it 'with values given by CSV file' do
      db.query('SELECT id FROM knights').to_i.should eql 10
      db.query('SELECT name FROM knights').to_s.should eql 'Karadoc'
    end
  end

  describe 'with column mapping' do
    before do
      @file = write_file [ %w(id nom), %w(10 Karadoc) ]
    end

    it 'with database column as string, a new line must be inserted' do
      CsvFastImporter.import @file, mapping: { nom: 'name' }
      row_count.should eql 1
    end

    it 'with file column as string, a new line must be inserted' do
      CsvFastImporter.import @file, mapping: { 'nom' => :name }
      row_count.should eql 1
    end
  end

  describe 'with column mapping and upper case file header' do
    before do
      @file = write_file [ %w(ID NOM), %w(10 Karadoc) ]
    end

    it 'with database column as string, a new line must be inserted' do
      CsvFastImporter.import @file, mapping: { nom: 'name' }
      row_count.should eql 1
    end

    it 'with file column as string, a new line must be inserted' do
      CsvFastImporter.import @file, mapping: { 'nom' => :name }
      row_count.should eql 1
    end
  end

  describe 'with default configuration' do
    before do
      file = write_file [ %w(id name), %w(10 Karadoc) ]
      @inserted_rows_count = CsvFastImporter.import file
    end

    it 'a new line must be inserted' do
      row_count.should eql 1
    end

    it 'with values given by CSV file' do
      db.query('SELECT id FROM knights').to_i.should eql 10
      db.query('SELECT name FROM knights').to_s.should eql 'Karadoc'
    end

    it 'must return inserted row count' do
      @inserted_rows_count.should eql 1
    end
  end

  describe 'with "-" in destination table name' do

    before do
      ActiveRecord::Base.connection.execute <<-SQL
        DROP TABLE IF EXISTS #{db.identify('arthur-knights')};
      SQL
      ActiveRecord::Base.connection.execute <<-SQL
        CREATE TABLE #{db.identify('arthur-knights')} ( name varchar(32) NULL );
      SQL
      csv_writer = CSVWriter.new 'arthur-knights.csv'
      file = csv_writer.create [ %w(name), %w(Karadoc) ]
      CsvFastImporter.import file
    end

    it 'a new line must be inserted' do
      db.query("SELECT COUNT(*) FROM #{db.identify('arthur-knights')}").to_i.should eql 1
    end
  end

  describe 'with database column with special character' do

    before do
      # TODO Execute multiple SQL queries with one statement (MySQL)
      ActiveRecord::Base.connection.execute <<-SQL
        DROP TABLE IF EXISTS #{db.identify('knights')};
      SQL
      ActiveRecord::Base.connection.execute <<-SQL
        CREATE TABLE #{db.identify('knights')} ( #{db.identify('-name')} varchar(32) NULL );
      SQL
      csv_writer = CSVWriter.new 'knights.csv'
      file = csv_writer.create [ %w(-name), %w(Karadoc) ]
      CsvFastImporter.import file
    end

    it 'should escape column names' do
      db.query('SELECT COUNT(*) FROM knights').to_i.should eql 1
    end
  end

  describe 'with custom row index column', skip_mysql: true do
    before do
      file = write_file [ %w(id name), %w(1 Karadoc), %w(2 Lancelot) ]
      CsvFastImporter.import file, row_index_column: 'row_index'
    end

    it 'should inserted row index in given column' do
      db.query("SELECT row_index FROM knights WHERE name = 'Lancelot'").to_i.should eql 2
    end
  end

  describe 'without deletion' do
    before do
      insert_one_row
      file = write_file [ %w(id name), %w(10 Karadoc) ]
      @inserted_rows_count = CsvFastImporter.import file, deletion: :none
    end

    it 'should append imported file to existing rows' do
      row_count.should eql 2
    end

    it 'should return inserted rows count' do
      @inserted_rows_count.should eql 1
    end
  end
end

