require_relative './database_connection'
require_relative './database/mysql'
require_relative './database/postgres'

module CsvFastImporter

  # Build corresponding CsvFastImporter database implementation based on current adapter (fetched from DatabaseConnection)
  module DatabaseFactory
    DATABASES = { postgresql: CsvFastImporter::Database::Postgres,
                  mysql2: CsvFastImporter::Database::Mysql
                }

    def self.build
      adapter = CsvFastImporter::DatabaseConnection.adapter_name
      raise "Database adapter #{adapter} not supported by CsvFastImporter. Only #{DATABASES.keys.join(", ")} are supported" unless DATABASES.has_key?(adapter)
      return DATABASES[adapter].new(CsvFastImporter::DatabaseConnection.base_connection)
    end
  end
end
