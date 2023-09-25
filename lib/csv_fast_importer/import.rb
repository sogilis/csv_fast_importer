require_relative './database_factory'

module CsvFastImporter

  # Import a file in database according a given configuration
  class Import

    def initialize(configuration)
      @configuration = configuration
      @db = CsvFastImporter::DatabaseFactory.build
    end

    def run
      @db.verify_compatibility @configuration
      row_index = 0
      within_transaction do
        truncate target_table
        row_index = @db.bulk_import(@configuration.file,
                                   target_table,
                                   target_columns,
                                   row_index_column: @configuration.row_index_column,
                                   column_separator: @configuration.column_separator,
                                   encoding:         @configuration.encoding)
      end
      row_index
    end

    private

    def truncate(table)
      return unless @configuration.deletion?
      if @configuration.truncate?
        @db.truncate table
      else
        @db.delete_all table
      end
    end

    def target_columns
      file_columns = @configuration.file
                                  .gets
                                  .split(@configuration.column_separator)
                                  .map(&:strip)
      db_columns = file_columns.map(&:downcase)
                               .map { |column| @configuration.mapping[column] || column }
      @db_columns ||= db_columns
    end

    def within_transaction
      if @configuration.transactional?
        @db.transaction do
          yield
        end
      else
        yield
      end
    end

    def target_table
      @configuration.destination_table
    end
  end
end
