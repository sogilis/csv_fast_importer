require_relative './database_helper.rb'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }

  TestDatabase::ALL_TYPES.each do |db_type|
    if db_type == TEST_DATABASE.type
      config.filter_run_excluding "skip_#{db_type}".to_sym => true
    else
      config.filter_run_excluding db_type => true
    end
  end
end

