require 'codacy-coverage'
Codacy::Reporter.start

require 'active_record'
require 'pathname'

test_dir = Pathname.new File.dirname(__FILE__)

%w(database_helper spec_helper database_helper).each { |file| require test_dir.join(file) }
