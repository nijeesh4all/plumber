# frozen_string_literal: true
require_relative '../../../config/database'
require_relative '../../application_source'

module Rently
  module Source
    class Users < ApplicationSource

      def initialize(columns, batch_size = 1000)
        super(columns, batch_size)
        @database = Database.setup("rently")
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
    end
  end
end
