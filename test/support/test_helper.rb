require 'codacy-coverage'
Codacy::Reporter.start

require 'active_record'
require 'pathname'

test_dir = Pathname.new File.dirname(__FILE__)
ActiveRecord::Base.configurations["test"] = YAML.load_file(test_dir.join("database.yml"))
ActiveRecord::Base.establish_connection :test


require test_dir.join('database_helper')
