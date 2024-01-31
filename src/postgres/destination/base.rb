# frozen_string_literal: true

module Postgres
  module Destination
    # The Base class serves as the foundation for PostgreSQL destination classes in ETL pipelines.
    # It provides methods for initializing the destination with database and table information,
    # writing rows to the database, and managing the prepared write statement for efficient execution.
    #
    # @example:
    #   destination = Postgres::Destination::Base.new(database_name: 'my_database', columns: ['name', 'age'],
    #                                                   table_name: 'users', primary_key: 'id')
    #   destination.write({ 'name' => 'John', 'age' => 25, 'id' => 1 })
    class Base
      attr_reader :primary_key, :table_name, :database

      def initialize(database_name:, columns: nil, table_name: nil, primary_key: 'id')
        @columns = columns
        @primary_key = primary_key
        @database = Database.setup(database_name)
        @table_name = table_name
        @logger = PipelineLogger.instance
        @logger.info "writing columns #{columns} to table #{table_name} on #{database_name} db"
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
          INSERT INTO #{table_name} (#{columns.join(', ')})
          VALUES (#{values_placeholder})
          ON CONFLICT (#{primary_key})
          DO UPDATE SET #{columns.map { |col| "#{col} = EXCLUDED.#{col}" }.join(', ')}
        SQL
      end

      # @return [String] a string of placeholders for the values in the query
      #   eg:- if there are 5 values to be inserted it will return "$1,$2,$3,$4,$5"
      def values_placeholder
        (1..columns.length).to_a.map { |i| "$#{i}" }.join(', ')
      end

      def prepared_statement_name
        [self.class.name, table_name, primary_key].join('_')
      end

      def prepare_write_statement!
        @logger.debug "prepared_statement #{prepared_statement_name}, #{write_query.gsub(/(\s+)/, ' ')}"
        @prepare_write_statement ||= @database.connection.prepare prepared_statement_name, write_query
      end
    end
  end
end
