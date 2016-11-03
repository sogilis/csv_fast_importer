require 'csv_fast_importer/version'
require 'active_record'
require 'configuration'

class CsvFastImporter

  def self.import(file, parameters = {})
    configuration = Configuration.new file, parameters

    sql_table = configuration.destination_table
    sql_columns = column_names(file, configuration).join(',')

    row_index = 0
    within_transaction_if(configuration.transactional?) do
      if configuration.deletion?
        if configuration.truncate?
          sql_connection.execute "TRUNCATE TABLE \"#{sql_table}\""
        else
          sql_connection.execute "DELETE FROM \"#{sql_table}\""
        end
      end
      sql_connection.raw_connection.copy_data <<-SQL do
        COPY "#{sql_table}" (#{sql_columns})
        FROM STDIN
        DELIMITER '#{configuration.column_separator}'
        CSV
        ENCODING '#{configuration.encoding}';
      SQL
        while line = file.gets do
          row_index += 1
          line.prepend row_index.to_s << configuration.column_separator if configuration.insert_row_index?
          sql_connection.raw_connection.put_copy_data line
        end
      end
    end
    row_index
  end

  def self.column_names(file, configuration)
    file_columns = file.gets
                       .split(configuration.column_separator)
                       .map(&:strip)
    sql_columns = file_columns.map(&:downcase).map do |column|
                    configuration.mapping[column] || column
                  end
    sql_columns.unshift configuration.row_index_column if configuration.insert_row_index?
    sql_columns
  end

  def self.within_transaction_if(transactional)
    if transactional
      sql_connection.transaction do
        yield
      end
    else
      yield
    end
  end

  def self.sql_connection
    ActiveRecord::Base.connection
  end

end
