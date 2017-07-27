require 'csv_fast_importer'
require_relative 'support/test_helper'
require_relative 'support/csv_writer'

describe CsvFastImporter do
  include_context 'knights table with columns row_index, id and name'

  describe 'with MySQL database', skip_postgres: true do
    let(:file) { write_file [ %w(id name), %w(10 Karadoc) ] }
    let(:parameters) { nil }
    subject { CsvFastImporter.import file, parameters }

    describe 'with enabled transaction' do
      let(:parameters) { { transaction: :enabled } }

      it 'throws exception' do
        lambda { subject }.should raise_error('Transactional not supported with MySQL database')
      end
    end
  end

  describe 'when importation fail', skip_mysql: true do
    before do
      insert_one_row
    end

    def import_with_exception(parameters = {})
      begin
        file = write_file [ %w(id, bad_column_name), %w(1, random_value1) ]
        CsvFastImporter.import file, parameters
        raise 'Unexpected here. Exception should have been raised'
      rescue
        # Stifled exception
      end
    end

    describe 'with default transaction configuration' do
      before do
        import_with_exception
      end

      it 'should not delete existing rows' do
        table_empty?.should be_falsey
      end
    end

    describe 'with enabled transaction' do
      before do
        import_with_exception transaction: :enabled
      end

      it 'should not delete existing rows' do
        table_empty?.should be_falsey
      end
    end

    describe 'with disabled transaction' do
      before do
        import_with_exception transaction: :disabled
      end

      it 'should delete existing rows' do
        table_empty?.should be_truthy
      end
    end
  end
end
