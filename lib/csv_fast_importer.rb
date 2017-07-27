require 'csv_fast_importer/version'
require 'configuration'
require 'importation'

class CsvFastImporter

  def self.import(file, parameters = {})
    configuration = Configuration.new file, parameters
    Importation.new(configuration).run
  end

end
