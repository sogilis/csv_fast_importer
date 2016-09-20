require 'mysql_helper'
require 'postgres_helper'

module DatabaseFactory
  DATABASES = { postgresql: PostgresHelper,
                mysql2: MysqlHelper
              }

  def self.build(adapter)
    return DATABASES[adapter].new if DATABASES.has_key?(adapter)
    raise "Database adapter #{adapter} not supported by CsvFastImporter. Only #{DATABASES.keys.join(", ")} are supported"
  end
end
