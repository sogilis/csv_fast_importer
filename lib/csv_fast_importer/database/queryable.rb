module CsvFastImporter
  module Database

    # Inherit from this class to create new custom database implementation
    # Do not forget to call .identifier_quote_character
    class Queryable

      def initialize(connection)
        @connection = connection
      end

      # Character used around identifiers (table or column name) to handle special characters
      def self.identifier_quote_character(character)
        define_method "identify" do |identifier|
          character + identifier + character
        end
      end

      def identify(table_or_column)
        raise '#identify method not available. #identifier_quote_character is certainly missing'
      end

      def connection
        @connection.raw_connection
      end

      def execute(query)
        @connection.execute query
      end

      def query(query)
        @connection.select_value query
      end

      def transaction
        @connection.transaction do
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
