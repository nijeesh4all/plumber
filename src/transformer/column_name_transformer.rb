# frozen_string_literal: true
require_relative '../application_transformer'

class ColumnNameTransformer
  def initialize(columns_map = {})
    @columns_map = columns_map
  end

  def process(row)
    new_row = {}
    row.each do |old_name, value|
      new_name = @columns_map[old_name] || old_name
      new_row[new_name] = value
    end
    debugger
    new_row
  end
end
