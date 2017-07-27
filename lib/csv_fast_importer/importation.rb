require 'active_record'
require 'csv_fast_importer/connection_helper'
require 'csv_fast_importer/database_factory'

module CsvFastImporter
  class Importation

    def initialize(configuration)
      @configuration = configuration
    end

    def run
      @db = CsvFastImporter::DatabaseFactory.build(CsvFastImporter::ConnectionHelper.adapter_name)
      @db.verify_compatibility @configuration

      row_index = 0
      within_transaction_if(@configuration.transactional?) do
        table = @configuration.destination_table
        columns = db_columns(@configuration)
        if @configuration.deletion?
          if @configuration.truncate?
            @db.truncate table
          else
            @db.delete_all table
          end
        end
        row_index = @db.bulk_import(@configuration.file,
                                    table,
                                    columns,
                                    row_index_column: @configuration.row_index_column,
                                    column_separator: @configuration.column_separator,
                                    encoding:         @configuration.encoding)
      end
      row_index
    end

    def db_columns(configuration)
      file_columns = configuration.file
                                  .gets
                                  .split(configuration.column_separator)
                                  .map(&:strip)
      db_columns = file_columns.map(&:downcase)
                               .map { |column| configuration.mapping[column] || column }
      db_columns
    end

    def within_transaction_if(transactional)
      if transactional
        @db.transaction do
          yield
        end
      else
        yield
      end
    end

  end
end
