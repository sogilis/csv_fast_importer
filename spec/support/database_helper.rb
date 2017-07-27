require ROOT_DIR.join('spec/config/database.rb')
establish_connection

ActiveRecord::Schema.define do

=begin
  create_table :schema_info, :force=>true do |t|
    t.column :version, :integer, :unique=>true
  end
  #SchemaInfo.create :version=>SchemaInfo::VERSION

  create_table :group, :force => true do |t|
    t.column :order, :string
    t.timestamps null: true
  end
=end

end

require ROOT_DIR.join('lib/csv_fast_importer/database_factory.rb')

module DatabaseHelper
  def db
    @db ||= CsvFastImporter::DatabaseFactory.build
  end
end
