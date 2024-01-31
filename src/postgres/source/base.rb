# frozen_string_literal: true

require_relative '../../../config/database'

module Postgres
  module Source
    # This module provides a base class for interacting with a PostgreSQL database as a data source.
    # It allows querying specific columns from a table with optional filtering and batch processing.
    # Usage:
    #   - Initialize with the database name, columns, batch size, table name, and optional where clause.
    #   - Utilize the 'each' method to iterate over batches of records from the specified table.
    #   - The 'count' method returns the total number of records in the specified table or with the given where clause.
    #
    # Example:
    #   source = Postgres::Source::Base.new(database_name: 'my_database', columns: ['name', 'age'], table_name: 'users',
    #                                                                                 where_clause: 'age > 21')
    #   source.each { |row| process_row(row) }
    #   total_records = source.count
    #
    class Base
      attr_reader :batch_size, :database_name, :table_name, :where_clause

      def initialize(database_name:, columns: nil, batch_size: 1000, table_name: nil, where_clause: nil)
        @database = Database.setup(database_name)
        @columns = columns
        @batch_size = batch_size
        @table_name = table_name
        @where_clause = where_clause
        @logger = PipelineLogger.instance
        @logger.info "querying columns #{columns} to table #{table_name} on #{database_name} db"
      end

      # rubocop:disable Metrics/MethodLength
      def each
        offset = 0
        row_count = 0
        @logger.info "total records to sync #{count}"

        loop do
          query = "#{select_query} OFFSET #{offset} LIMIT #{batch_size}"
          @logger.info 'running query', query

          results = @database.connection.exec(query)

          # Check if any rows were returned
          break if results.ntuples.zero?

          # Print each row within the current batch
          results.each do |row|
            yield row
            row_count += 1
          end

          # Update offset and check if reached max batch size
          offset += batch_size
          break if row_count >= batch_size
        end
      end
      # rubocop:enable Metrics/MethodLength

      def count
        count_query = select_query('COUNT(*)')
        @database.connection.exec(count_query).first['count'].to_i
      end

      private

      def select_query(columns = self.columns)
        query = "SELECT #{columns} FROM #{table_name}"
        query += " WHERE #{where_clause}" unless where_clause.nil?
        query
      end

      def columns
        @columns.nil? ? '*' : @columns.join(', ')
      end
    end
  end
end
