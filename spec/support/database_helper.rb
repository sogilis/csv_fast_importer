require ROOT_DIR.join('spec/config/test_database.rb')

TEST_DATABASE = TestDatabase.new
TEST_DATABASE.connect

require ROOT_DIR.join('lib/csv_fast_importer/database_factory.rb')

module DatabaseHelper
  def db
    @db ||= CsvFastImporter::DatabaseFactory.build
  end
end
