require 'csv_fast_importer'
require_relative 'support/test_helper'
require_relative 'support/csv_writer'

describe CsvFastImporter do
  include_context 'test_kaamelott table with columns row_index, id and label'

  before do
    @csv_writer = CSVWriter.new 'test_kaamelott.csv'
  end

  describe 'with custom column separator' do
    before do
      file = @csv_writer.create [ %w(label id), %w(kadoc 10) ], col_sep: '|'
      CsvFastImporter.import file, col_sep: '|'
    end

    it 'a new line must be inserted' do
      row_count.should eql 1
    end
  end

  describe 'with custom file encoding' do
    before do
      file = @csv_writer.create [ %w(label id), %w(libellé 10) ], encoding: 'ISO-8859-1'
      CsvFastImporter.import file, encoding: 'ISO-8859-1'
    end

    it 'must import with correct encoding' do
      sql_select('SELECT label FROM test_kaamelott').to_s.should eql 'libellé'
    end
  end

  describe 'with custom file table destination' do
    before do
      filepath = @csv_writer.create [ %w(label id), %w(kadoc 10) ]
      @file = File.new filepath
      CsvFastImporter.import @file, destination: 'test_kaamelott'
    end

    it 'a new line must be inserted' do
      row_count.should eql 1
    end
  end

  describe 'without same column order between csv header and database table' do
    before do
      file = @csv_writer.create [ %w(label id), %w(kadoc 10) ]
      CsvFastImporter.import file
    end

    it 'a new line must be inserted' do
      row_count.should eql 1
    end

    it 'with values given by CSV file' do
      sql_select('SELECT id FROM test_kaamelott').to_i.should eql 10
      sql_select('SELECT label FROM test_kaamelott').to_s.should eql 'kadoc'
    end
  end

  describe 'with column mapping' do
    before do
      @file = @csv_writer.create [ %w(id label), %w(10 kadoc) ]
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
      @file = @csv_writer.create [ %w(ID LIBELLE), %w(10 kadoc) ]
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

  describe 'with default values' do
    before do
      file = @csv_writer.create [ %w(id label), %w(10 kadoc) ]
      @inserted_rows = CsvFastImporter.import file
    end

    it 'a new line must be inserted' do
      row_count.should eql 1
    end

    it 'with values given by CSV file' do
      sql_select('SELECT id FROM test_kaamelott').to_i.should eql 10
      sql_select('SELECT label FROM test_kaamelott').to_s.should eql 'kadoc'
    end

    it 'must return inserted row count' do
      @inserted_rows.should eql 1
    end
  end

  describe 'with "-" in destination table name' do

    before do
      ActiveRecord::Base.connection.execute <<-SQL
        DROP TABLE IF EXISTS "special-character";
        CREATE TABLE "special-character" ( label varchar NULL );
      SQL
      csv_writer = CSVWriter.new 'special-character.csv'
      file = csv_writer.create [ %w(label), %w(kadoc) ]
      @inserted_rows = CsvFastImporter.import file
    end

    it 'a new line must be inserted' do
      sql_select('SELECT COUNT(*) FROM "special-character"').to_i.should eql 1
    end
  end

  describe 'with custom row index column' do
    before do
      file = @csv_writer.create [ %w(id label), %w(1 kadoc), %w(2 lancelot) ]
      CsvFastImporter.import file, row_index_column: 'row_index'
    end

    it 'should inserted row index in given column' do
      sql_select("SELECT row_index FROM test_kaamelott WHERE label = 'lancelot'").to_i.should eql 2
    end
  end
end

