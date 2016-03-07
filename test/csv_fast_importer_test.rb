require 'minitest/autorun'
require_relative 'support/test_helper'
require 'csv_fast_importer'
require_relative 'support/csv_writer'

describe 'When CSV file is imported with CsvFastImporter' do

  before do
    @csv_writer = CSVWriter.new 'test_kaamelott.csv'
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS test_kaamelott;
      CREATE TABLE test_kaamelott ( id serial NOT NULL, label varchar(32) NOT NULL );
    SQL
  end

  describe 'with custom column separator' do
    before do
      file = @csv_writer.create [ %w(label id), %w(kadoc 10) ], col_sep: '|'
      CsvFastImporter.import file, col_sep: '|'
    end

    it 'a new line must be inserted' do
      assert_equal 1, row_count
    end
  end

  describe 'with custom file encoding' do
    before do
      file = @csv_writer.create [ %w(label id), %w(libellé 10) ], encoding: 'ISO-8859-1'
      CsvFastImporter.import file, encoding: 'ISO-8859-1'
    end

    it 'must import with correct encoding' do
      assert_equal 'libellé', sql_select('SELECT label FROM test_kaamelott').to_s
    end
  end

  describe 'with custom file table destination' do
    before do
      filepath = @csv_writer.create [ %w(label id), %w(kadoc 10) ]
      @file = File.new filepath
      CsvFastImporter.import @file, destination: 'test_kaamelott'
    end

    it 'a new line must be inserted' do
      assert_equal 1, row_count
    end
  end

  describe 'without same column order between csv header and database table' do
    before do
      file = @csv_writer.create [ %w(label id), %w(kadoc 10) ]
      CsvFastImporter.import file
    end

    it 'a new line must be inserted' do
      assert_equal 1, row_count
    end

    it 'with values given by CSV file' do
      assert_equal 10, sql_select('SELECT id FROM test_kaamelott').to_i
      assert_equal 'kadoc', sql_select('SELECT label FROM test_kaamelott').to_s
    end
  end

  describe 'with column mapping' do
    before do
      @file = @csv_writer.create [ %w(id label), %w(10 kadoc) ]
    end

    it 'with database column as string, a new line must be inserted' do
      CsvFastImporter.import @file, mapping: { libelle: 'label' }
      assert_equal 1, row_count
    end

    it 'with file column as string, a new line must be inserted' do
      CsvFastImporter.import @file, mapping: { 'libelle' => :label }
      assert_equal 1, row_count
    end
  end

  describe 'with column mapping and upper case file header' do
    before do
      @file = @csv_writer.create [ %w(ID LIBELLE), %w(10 kadoc) ]
    end

    it 'with database column as string, a new line must be inserted' do
      CsvFastImporter.import @file, mapping: { libelle: 'label' }
      assert_equal 1, row_count
    end

    it 'with file column as string, a new line must be inserted' do
      CsvFastImporter.import @file, mapping: { 'libelle' => :label }
      assert_equal 1, row_count
    end
  end

  describe 'with default values' do
    before do
      file = @csv_writer.create [ %w(id label), %w(10 kadoc) ]
      @inserted_rows = CsvFastImporter.import file
    end

    it 'a new line must be inserted' do
      assert_equal 1, row_count
    end

    it 'with values given by CSV file' do
      assert_equal 10, sql_select('SELECT id FROM test_kaamelott').to_i
      assert_equal 'kadoc', sql_select('SELECT label FROM test_kaamelott').to_s
    end

    it 'must return inserted row count' do
      assert_equal 1, @inserted_rows
    end
  end

  def sql_select(sql_query)
    ActiveRecord::Base.connection.select_value sql_query
  end

  def row_count
    sql_select('SELECT COUNT(*) FROM test_kaamelott').to_i
  end
end
