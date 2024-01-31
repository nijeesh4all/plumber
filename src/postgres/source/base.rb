# frozen_string_literal: true

require_relative '../../../config/database'

module Postgres
  module Source
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
