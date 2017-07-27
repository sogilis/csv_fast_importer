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

%w(database_factory.rb connection_helper.rb).each do |file|
  require ROOT_DIR.join('lib/csv_fast_importer').join(file)
end

module DatabaseHelper
  def db
    @db ||= CsvFastImporter::DatabaseFactory.build(CsvFastImporter::ConnectionHelper.adapter_name)
  end
end
