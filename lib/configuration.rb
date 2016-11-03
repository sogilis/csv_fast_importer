class Configuration

  def initialize(file, parameters = {})
    @file = file
    @parameters = parameters
  end

  def encoding
    @encoding ||= @parameters[:encoding] || 'UTF-8'
  end

  def column_separator
    @column_separator ||= @parameters[:col_sep] || ';'
  end

  def mapping
    @mapping ||= downcase_keys_and_values(@parameters[:mapping] || {})
  end

  def destination_table
    @destination_table ||= (@parameters[:destination] || File.basename(@file, '.*'))
  end

  def row_index_column
    @row_index_column ||= @parameters[:row_index_column]
  end

  def insert_row_index?
    row_index_column.present?
  end

  def transactional?
    @transactional ||= !(@parameters[:transaction] == :disabled)
  end

  def truncate?
    @deletion ||= @parameters[:deletion] == :truncate
  end

  def deletion?
    @deletion ||= !(@parameters[:deletion] == :none)
  end

private

  def downcase_keys_and_values(hash)
    Hash[hash.map{ |k, v| [k.to_s.downcase, v.to_s.downcase] }]
  end

end
