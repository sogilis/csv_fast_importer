require_relative './database/mysql'
require_relative './database/postgres'

module CsvFastImporter

  # Build corresponding CsvFastImporter database implementation based on a given adapter (fetched from DatabaseConnection)
  module DatabaseFactory
    DATABASES = { postgresql: CsvFastImporter::Database::Postgres,
                  mysql2: CsvFastImporter::Database::Mysql
                }

    def self.build(adapter)
      return DATABASES[adapter].new if DATABASES.has_key?(adapter)
      raise "Database adapter #{adapter} not supported by CsvFastImporter. Only #{DATABASES.keys.join(", ")} are supported"
    end
  end
end