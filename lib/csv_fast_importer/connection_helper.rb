require 'active_record'

module CsvFastImporter

  # Provide access to database driver/adapter
  class ConnectionHelper

    def self.adapter_name
      @adapter_name ||= base_connection.adapter_name
                                      .downcase
                                      .to_sym
    end

    def self.base_connection
      @base_connection ||= ActiveRecord::Base.connection
    end

  end
end
