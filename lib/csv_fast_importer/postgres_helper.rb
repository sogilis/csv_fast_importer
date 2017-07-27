require 'csv_fast_importer/database_operations'

module CsvFastImporter
  class PostgresHelper
    include CsvFastImporter::DatabaseOperations

    identifier_quote_character '"'

    def verify_compatibility(configuration)
      #TODO verify postgresql version
    end

    def bulk_import(file, table, columns, row_index_column: nil, column_separator:, encoding:)
      sql_columns = columns
      sql_columns = [row_index_column] + sql_columns unless row_index_column.nil?
      columns_list_query = sql_columns.map { |column| identify(column) }
                                      .join(',')

      row_index = 0
      connection.copy_data <<-SQL do
        COPY #{identify(table)} (#{columns_list_query})
        FROM STDIN
        DELIMITER '#{column_separator}'
        CSV
        ENCODING '#{encoding}';
      SQL
        while line = file.gets do
          row_index += 1
          line.prepend row_index.to_s << column_separator unless row_index_column.nil?
          connection.put_copy_data line
        end
      end
      row_index
    end
  end
end
