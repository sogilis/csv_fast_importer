ActiveRecord::Base.configurations["test"] = YAML.load_file('spec/config/database.yml')
ActiveRecord::Base.establish_connection :test

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
