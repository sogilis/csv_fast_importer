require 'csv_fast_importer/database_connection'

module CsvFastImporter
  module Database

    # Include this module on a custom database implementation to enable commons query methods
    # Do not forget to call .identifier_quote_character after that
    module Queryable

      module ClassMethods
        # Character used around identifiers (table or column name) to handle special characters
        def identifier_quote_character(character)
          define_method "identify" do |identifier|
            character + identifier + character
          end
        end
      end

      def self.included(base)
        base.extend ClassMethods
      end

      def identify(table_or_column)
        raise '#identify method not available. #identifier_quote_character is certainly missing'
      end

      def connection
        DatabaseConnection.base_connection.raw_connection
      end

      def execute(query)
        DatabaseConnection.base_connection.execute query
      end

      def query(query)
        DatabaseConnection.base_connection.select_value query
      end

      def transaction
        DatabaseConnection.base_connection.transaction do
          yield
        end
      end

      def delete_all(table)
        execute "DELETE FROM #{identify(table)}"
      end

      def truncate(table)
        execute "TRUNCATE TABLE #{identify(table)}"
      end

    end
  end
end