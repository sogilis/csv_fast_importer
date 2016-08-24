require 'csv_fast_importer'
require_relative 'support/test_helper'
require_relative 'support/csv_writer'

describe CsvFastImporter do
  include_context 'test_kaamelott table with columns row_index, id and label'

  describe 'when importation fail' do
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

    describe 'with enabled disabled' do
      before do
        import_with_exception transaction: :disabled
      end

      it 'should delete existing rows' do
        table_empty?.should be_truthy
      end
    end
  end
end
