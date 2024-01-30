# frozen_string_literal: true

require_relative '../src/armor/destination/agent_identities'
require_relative '../src/rently/source/agents'
require_relative '../src/transformer/column_name_transformer'

class ArmorAgentSync
  module SyncJob
    module_function

    def setup(config)
      Kiba.parse do

        # responsible for reading the data
        source Rently::Source::Agents, %w[id email encrypted_password reset_password_token reset_password_sent_at remember_created_at sign_in_count current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip user_id fullname voice_phone active created_at updated_at role salesforce_id deleted_at armor_id]

        transform ColumnNameTransformer, {
          "id" => "rently_id",
          "user_id" => "company_id",
          "armor_id" => "id"
        }

        # responsible for writing the data
        destination Armor::Destination::AgentIdentities, %w[email id encrypted_password reset_password_token reset_password_sent_at remember_created_at sign_in_count current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip created_at updated_at company_id api_user deleted_at active fullname salesforce_id rently_agent_last_updated role voice_phone rently_id]
      end
    end
  end
end