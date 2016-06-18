require 'codacy-coverage'
Codacy::Reporter.start

require 'active_record'
require 'pathname'

test_dir = Pathname.new File.dirname(__FILE__)
ActiveRecord::Base.configurations["test"] = YAML.load_file(test_dir.join("database.yml"))
ActiveRecord::Base.establish_connection :test

%w(database_helper spec_helper).each { |file| require test_dir.join(file) }
