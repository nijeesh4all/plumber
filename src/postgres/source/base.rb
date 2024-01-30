# frozen_string_literal: true

class Postgres
  module Source
    class Base
      attr_reader :batch_size, :columns, :database_name, :source_table_name
      def initialize(database_name:, columns: nil , batch_size: 1000, source_table_name: nil)
        @database = Database.setup(database_name)
        @columns = columns
        @batch_size = batch_size
        @source_table_name = source_table_name || table_name_from_class
      end

      def each
        offset = 0
        row_count = 0

        loop do
          query = "#{select_query} OFFSET #{offset} LIMIT #{batch_size}"

          results = @database.connection.exec(query)

          # Check if any rows were returned
          if results.ntuples == 0
            break
          end

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

      def table_name_from_class
        self.class.name.split("::").last
      end

      def select_query(columns = self.columns)
        "SELECT #{columns} FROM #{source_table_name}"
      end

      def columns
        @columns.nil? ? '*' : @columns.join(', ')
      end

    end

  end
end
