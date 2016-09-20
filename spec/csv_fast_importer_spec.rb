require 'csv_fast_importer'
require_relative 'support/test_helper'
require_relative 'support/csv_writer'

describe CsvFastImporter do
  include DatabaseHelper
  include_context 'test_kaamelott table with columns row_index, id and label'

  describe 'with custom column separator' do
    before do
      file = write_file [ %w(label id), %w(kadoc 10) ], col_sep: '|'
      CsvFastImporter.import file, col_sep: '|'
    end

    it 'a new line must be inserted' do
      row_count.should eql 1
    end
  end

  describe 'with custom file encoding', skip_mysql: true do
    before do
      file = write_file [ %w(label id), %w(libellé 10) ], encoding: 'ISO-8859-1'
      CsvFastImporter.import file, encoding: 'ISO-8859-1'
    end

    it 'must import with correct encoding' do
      db.query('SELECT label FROM test_kaamelott').to_s.should eql 'libellé'
    end
  end

  describe 'with custom file table destination' do
    before do
      filepath = write_file [ %w(label id), %w(kadoc 10) ]
      @file = File.new filepath
      CsvFastImporter.import @file, destination: 'test_kaamelott'
    end

    it 'a new line must be inserted' do
      row_count.should eql 1
    end
  end

  describe 'without same column order between csv header and database table' do
    before do
      file = write_file [ %w(label id), %w(kadoc 10) ]
      CsvFastImporter.import file
    end

    it 'a new line must be inserted' do
      row_count.should eql 1
    end

    it 'with values given by CSV file' do
      db.query('SELECT id FROM test_kaamelott').to_i.should eql 10
      db.query('SELECT label FROM test_kaamelott').to_s.should eql 'kadoc'
    end
  end

  describe 'with column mapping' do
    before do
      @file = write_file [ %w(id label), %w(10 kadoc) ]
    end

    it 'with database column as string, a new line must be inserted' do
      CsvFastImporter.import @file, mapping: { libelle: 'label' }
      row_count.should eql 1
    end

    it 'with file column as string, a new line must be inserted' do
      CsvFastImporter.import @file, mapping: { 'libelle' => :label }
      row_count.should eql 1
    end
  end

  describe 'with column mapping and upper case file header' do
    before do
      @file = write_file [ %w(ID LIBELLE), %w(10 kadoc) ]
    end

    it 'with database column as string, a new line must be inserted' do
      CsvFastImporter.import @file, mapping: { libelle: 'label' }
      row_count.should eql 1
    end

    it 'with file column as string, a new line must be inserted' do
      CsvFastImporter.import @file, mapping: { 'libelle' => :label }
      row_count.should eql 1
    end
  end

  describe 'with default configuration' do
    before do
      file = write_file [ %w(id label), %w(10 kadoc) ]
      @inserted_rows_count = CsvFastImporter.import file
    end

    it 'a new line must be inserted' do
      row_count.should eql 1
    end

    it 'with values given by CSV file' do
      db.query('SELECT id FROM test_kaamelott').to_i.should eql 10
      db.query('SELECT label FROM test_kaamelott').to_s.should eql 'kadoc'
    end

    it 'must return inserted row count' do
      @inserted_rows_count.should eql 1
    end
  end

  describe 'with "-" in destination table name' do

    before do
      ActiveRecord::Base.connection.execute <<-SQL
        DROP TABLE IF EXISTS #{db.identify('special-character')};
      SQL
      ActiveRecord::Base.connection.execute <<-SQL
        CREATE TABLE #{db.identify('special-character')} ( label varchar(32) NULL );
      SQL
      csv_writer = CSVWriter.new 'special-character.csv'
      file = csv_writer.create [ %w(label), %w(kadoc) ]
      CsvFastImporter.import file
    end

    it 'a new line must be inserted' do
      db.query("SELECT COUNT(*) FROM #{db.identify('special-character')}").to_i.should eql 1
    end
  end

  describe 'with database column with special character' do

    before do
      # TODO Execute multiple SQL queries with one statement (MySQL)
      ActiveRecord::Base.connection.execute <<-SQL
        DROP TABLE IF EXISTS #{db.identify('test_kaamelott')};
      SQL
      ActiveRecord::Base.connection.execute <<-SQL
        CREATE TABLE #{db.identify('test_kaamelott')} ( #{db.identify('-label')} varchar(32) NULL );
      SQL
      csv_writer = CSVWriter.new 'test_kaamelott.csv'
      file = csv_writer.create [ %w(-label), %w(kadoc) ]
      CsvFastImporter.import file
    end

    it 'should escape column names' do
      db.query('SELECT COUNT(*) FROM test_kaamelott').to_i.should eql 1
    end
  end

  describe 'with custom row index column', skip_mysql: true do
    before do
      file = write_file [ %w(id label), %w(1 kadoc), %w(2 lancelot) ]
      CsvFastImporter.import file, row_index_column: 'row_index'
    end

    it 'should inserted row index in given column' do
      db.query("SELECT row_index FROM test_kaamelott WHERE label = 'lancelot'").to_i.should eql 2
    end
  end

  describe 'without deletion' do
    before do
      insert_one_row
      file = write_file [ %w(id label), %w(10 kadoc) ]
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

