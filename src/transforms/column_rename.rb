# frozen_string_literal: true

module Transforms
  # The ColumnRename class represents a transformation that renames columns in a data row based on a provided mapping.
  # It takes a hash of column mappings during initialization and applies these mappings to rename the columns.
  #
  # Usage:
  #   - Initialize with a hash of column mappings.
  #   - Call the 'process' method to apply the column renaming transformation to a data row.
  #
  # Example:
  #   column_rename_transform = Transforms::ColumnRename.new(columns_map: { old_name1: :new_name1,
  #                                                                           old_name2: :new_name2 })
  #   transformed_row = column_rename_transform.process({ old_name1: 'value1', old_name2: 'value2' })
  class ColumnRename
    def initialize(columns_map: {})
      @columns_map = columns_map
    end

    def process(row)
      new_row = {}
      row.each do |old_name, value|
        old_name = old_name.to_sym
        new_name = @columns_map[old_name] || old_name
        new_row[new_name.to_s] = value
      end
      new_row
    end
  end
end
