require 'database_operations'

class MysqlHelper
  include DatabaseOperations

  identifier_quote_character '`'

  def verify_compatibility(configuration)
    raise 'Transactional not supported with MySQL database' if configuration.transactional_forced?
  end

  def bulk_import(file, table, columns, row_index_column: nil, column_separator:, encoding:)
    columns_list_query = columns.map { |column| identify(column) }.join(',')
    # TODO Test without enclosed field
    # TODO Test with \r\n and \n endline
    # TODO handle nulls
    # TODO Add row_inex column
    execute <<-SQL
        LOAD DATA LOCAL INFILE '#{File.expand_path(file)}'
        INTO TABLE #{identify(table)}
        CHARACTER SET UTF8
        FIELDS TERMINATED BY ';' OPTIONALLY ENCLOSED BY '"'
        LINES TERMINATED BY '\\n'
        IGNORE 1 LINES
        (#{columns_list_query})
        ;
      SQL
    query('SELECT ROW_COUNT()')
  end
end
