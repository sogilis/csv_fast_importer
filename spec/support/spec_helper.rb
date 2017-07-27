require ROOT_DIR.join('spec/config/database.rb')

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }

  ALL_DB_TYPES.each do |db_type|
    if db_type == DB_TYPE
      config.filter_run_excluding "skip_#{db_type}".to_sym => true
    else
      config.filter_run_excluding db_type => true
    end
  end
end

