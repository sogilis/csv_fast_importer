require 'bundler/gem_tasks'

namespace :test do
  namespace :db do

    desc "Create test database"
    task :create do

      require_relative './spec/config/test_database.rb'

      db = TestDatabase.new
      case db.type
        when :postgres
          require 'pg'
          db.connect 'postgres'
          ActiveRecord::Base.connection.execute "CREATE DATABASE #{db.name}"

        when :mysql
          require 'mysql2'
          client_config = db.configuration
                            .merge(database: nil,
                                   username: 'root',
                                   password: ENV['DB_ROOT_PASSWORD'],
                                   flags: Mysql2::Client::MULTI_STATEMENTS)
          client = Mysql2::Client.new(client_config)
          client.query <<-SQL
            CREATE DATABASE #{db.name};
            GRANT ALL ON #{db.name}.* TO '#{db.configuration['username']}'@'#{db.configuration['host']}';
            FLUSH PRIVILEGES;
          SQL
        else
          raise "Unknown database type: #{db.type}"
      end

      puts "Test database \"#{db.name}\" created."
    end

  end
end
