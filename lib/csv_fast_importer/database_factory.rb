require 'csv_fast_importer/mysql_helper'
require 'csv_fast_importer/postgres_helper'

module CsvFastImporter
  module DatabaseFactory
    DATABASES = { postgresql: CsvFastImporter::PostgresHelper,
                  mysql2: CsvFastImporter::MysqlHelper
                }

    def self.build(adapter)
      return DATABASES[adapter].new if DATABASES.has_key?(adapter)
      raise "Database adapter #{adapter} not supported by CsvFastImporter. Only #{DATABASES.keys.join(", ")} are supported"
    end
  end
end
