require 'yaml'
require 'pathname'

class TestDatabase
  ALL_TYPES = [:postgres, :mysql]

  attr_accessor :type, :configuration

  def initialize
    @type = (ENV['DB_TYPE'] || :postgres).to_sym

    unless ALL_TYPES.include?(@type)
      raise "Unknown database: #{@type}. Database type is defined with environment variabe \"@type\". Allowed values: #{ALL_TYPES}"
    end

    config_file = Pathname.new(File.dirname(__FILE__)).join("database.#{@type}.yml")
    @configuration = YAML.load_file(config_file)
    @configuration["host"] = ENV["DB_HOST"] if ENV.has_key? "DB_HOST"
    @configuration["post"] = ENV["DB_PORT"] if ENV.has_key? "DB_PORT"
    @configuration["username"] = ENV["DB_USERNAME"] if ENV.has_key? "DB_USERNAME"
    @configuration["password"] = ENV["DB_PASSWORD"] if ENV.has_key? "DB_PASSWORD"
    @configuration["database"] = ENV["DB_DATABASE"] if ENV.has_key? "DB_DATABASE"
  end

  def name
    @configuration["database"]
  end

  def connect(database = @configuration['database'])
    require 'active_record'
    ActiveRecord::Base.configurations["test"] = @configuration.merge(database: database)
    ActiveRecord::Base.establish_connection :test
  end
end
