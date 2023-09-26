require_relative './queryable'

module CsvFastImporter
  module Database
    class Postgres < Queryable
      identifier_quote_character '"'

      def verify_compatibility(configuration)
        #TODO verify postgresql version
      end

      def bulk_import(file, table, columns, row_index_column: nil, column_separator:, encoding:, &block)
        sql_columns = columns
        sql_columns = [row_index_column] + sql_columns unless row_index_column.nil?
        columns_list_query = sql_columns.map { |column| identify(column) }
                                        .join(',')

        file_columns = file.gets.split(column_separator).map(&:strip)

        row_index = 0
        connection.copy_data <<-SQL do
          COPY #{identify(table)} (#{columns_list_query})
          FROM STDIN
          DELIMITER '#{column_separator}'
          CSV
          ENCODING '#{encoding}';
        SQL
          while line = file.gets(chomp: true) do
            row_index += 1
            if block_given?
              values = line.split(column_separator)
              row = Hash[file_columns.zip(values)]
              block.call row
              line = row.values.join(column_separator)
            end
            line.prepend row_index.to_s << column_separator unless row_index_column.nil?
            connection.put_copy_data line << "\n"
          end
        end
        row_index
        # FIXME: file.close
      end
    end
  end
end
