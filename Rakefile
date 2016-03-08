require "bundler/gem_tasks"

task :default => :test
task :test do
  Dir.glob('./test/*_test.rb').each { |file| require file}
end

namespace :test do
  namespace :db do

    desc "Create test database"
    task :create do
      require 'pg'
      require 'yaml'

      db_config = YAML.load_file('test/support/database.yml')
      database_name = db_config['database']
      connection = PG.connect dbname: 'postgres', host: db_config['host'], port: db_config['port']
      connection.exec "CREATE DATABASE #{database_name}"
      puts "Test database \"#{database_name}\" created."
    end

  end
end