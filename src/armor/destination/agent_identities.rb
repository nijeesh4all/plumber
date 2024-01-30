# frozen_string_literal: true
require_relative '../../application_destination'

module Armor
  module Destination
    class AgentIdentities < ApplicationDestination

      def initialize(columns = nil, primary_key = "id")
        super(columns, primary_key)
        @database = Database.setup("armor")
        prepare_write_statement!
      end

      def table_name
        "agent_identities"
      end
    end
  end
end
