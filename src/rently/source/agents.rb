require_relative '../../application_source'

module Rently
  module Source
    class Agents < ApplicationSource
      def initialize(columns, batch_size = 1000)
        super(columns, batch_size)
        @database = Database.setup("rently")
      end
    end
  end
end
