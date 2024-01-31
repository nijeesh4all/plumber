# frozen_string_literal: true

module Transforms
  # The ValueCopy class represents a transformation that copies values from source columns to destination columns.
  # It takes a hash of column mappings during initialization and applies these mappings to copy values.
  #
  # Usage:
  #   - Initialize with a hash of column mappings specifying source and destination columns.
  #   - Call the 'process' method to apply the value copying transformation to a data row.
  #
  # Example:
  #   value_copy_transform = Transforms::ValueCopy.new(columns_map: { source_column1: :destination_column1,
  #                                                                   source_column2: :destination_column2 })
  #   transformed_row = value_copy_transform.process({ source_column1: 'value1', source_column2: 'value2' })
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
