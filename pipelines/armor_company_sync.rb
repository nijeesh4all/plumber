# frozen_string_literal: true

require 'kiba'
require_relative '../src/rently/source/users'
require_relative '../src/armor/destination/companies'

module ArmorCompanySync
  module SyncJob
    module_function

    COLUMNS = %w[id fullname created_at updated_at salesforce_id rently_id enable_multifamily
                 platform_mode authentication_status].freeze

    def setup(config)
      Kiba.parse do

        # responsible for reading the data
        source Rently::Source::Users, COLUMNS

        # responsible for writing the data
        destination Armor::Destination::Companies, COLUMNS
      end
    end
  end
end
