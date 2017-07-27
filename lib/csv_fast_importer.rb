require 'csv_fast_importer/version'
require 'csv_fast_importer/configuration'
require 'csv_fast_importer/importation'

module CsvFastImporter

  def self.import(file, parameters = {})
    configuration = CsvFastImporter::Configuration.new file, parameters
    CsvFastImporter::Importation.new(configuration).run
  end

end
