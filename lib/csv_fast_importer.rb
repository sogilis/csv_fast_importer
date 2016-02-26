require "csv_fast_importer/version"
require 'active_record'

class CsvFastImporter

  # TODO Add parameter to prevent transaction usage
  # TODO Allow caller to ignore columns
  # TODO Alert when mapped column is not found
  # TODO Check database is PostgreSQL

  # FIXME Remove defautl encoding
  DEFAULT_OPTIONS = { col_sep: ';', encoding: 'UTF-8' , mapping: {} }

  def self.import(file, new_options = {})
    options = DEFAULT_OPTIONS.merge(new_options)

    table_name = destination file, options
    column_names = columns file, options

    row_count = 0
    sql_connection.transaction do
      sql_connection.execute("DELETE FROM #{table_name}")
      sql_connection.raw_connection.copy_data <<-SQL do
        COPY #{table_name}(#{column_names.join(',')})
        FROM STDIN
        DELIMITER '#{options[:col_sep]}'
        CSV
        ENCODING '#{options[:encoding]}';
      SQL
        while line = file.gets do
          row_count += 1
          sql_connection.raw_connection.put_copy_data line
        end
      end
    end
    row_count
  end

  def self.destination(file, options)
    return options[:destination] if options.has_key? :destination
    File.basename file, '.*'
  end

  def self.columns(file, options)
    # TODO Manage quotes
    file_columns = file.gets.split(options[:col_sep]).map &:strip
    map_columns file_columns, options[:mapping]
  end

  def self.map_columns(columns, mapping)
    mapping_to_lower_case = Hash[mapping.map{ |k, v| [k.to_s.downcase, v.to_s.downcase] }]
    columns.map(&:downcase).map do |column|
      next mapping_to_lower_case[column].to_s if mapping_to_lower_case.has_key? column
      column
    end
  end

  def self.sql_connection
    ActiveRecord::Base.connection
  end

end