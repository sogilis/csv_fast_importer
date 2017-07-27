require 'codacy-coverage'
Codacy::Reporter.start

require 'pathname'
ROOT_DIR = Pathname.new(File.dirname(__FILE__)).join("../..")

%w(database_helper spec_helper).each do |file|
  require ROOT_DIR.join('spec/support').join(file)
end

Dir[ROOT_DIR.join("spec/context/**/*.rb")].each { |f| require f }


