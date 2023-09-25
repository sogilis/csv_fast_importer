require 'csv_fast_importer/version'
require 'csv_fast_importer/configuration'
require 'csv_fast_importer/import'

module CsvFastImporter

  def self.import(file, parameters = {}, &block)
    configuration = CsvFastImporter::Configuration.new file, parameters
    CsvFastImporter::Import.new(configuration).run(&block)
  end

end
