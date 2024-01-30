# frozen_string_literal: true

module Postgres
  module Destination
    class Base
      attr_reader :columns, :primary_key, :table_name, :database

      def initialize(database_name:, columns: nil, table_name: nil, primary_key: "id")
        @columns = columns
        @primary_key = primary_key
        @database = Database.setup(database_name)
        @table_name = table_name
        prepare_write_statement!
      end

      def write(row)
        @database.connection.exec_prepared(prepared_statement_name, values(row))
      end

      def values(row)
        row.values_at(*columns)
      end

      def columns
        Array(@columns)
      end

      private

      def write_query
        <<-SQL
          INSERT INTO #{table_name} (#{columns.join(", ")})
          VALUES (#{values_placeholder})
          ON CONFLICT (#{primary_key})
          DO UPDATE SET #{columns.map { |col| "#{col} = EXCLUDED.#{col}" }.join(", ")}
        SQL
      end

      # @return [String] a string of placeholders for the values in the query
      #   eg:- if there are 5 values to be inserted it will return "$1,$2,$3,$4,$5"
      def values_placeholder
        (1..columns.length).to_a.map { |i| "$#{i}" }.join(", ")
      end

      def prepared_statement_name
        self.class.name + table_name + primary_key
      end

      def prepare_write_statement!
        @prepared_statement ||= @database.connection.prepare prepared_statement_name, write_query
      end

    end
  end
end
