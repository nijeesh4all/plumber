# frozen_string_literal: true

module Transforms
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