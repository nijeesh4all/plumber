# frozen_string_literal: true

module Transforms
  class ValueCopy
    def initialize(columns_map: {})
      @columns_map = columns_map
    end

    def process(row)
      @columns_map.each do |source_column, destination_column|

        row[destination_column.to_s] = row[source_column.to_sym]
      end
      row
    end
  end

end