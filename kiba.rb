# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'kiba'

require_relative 'pipelines/armor_company_sync'
require_relative 'pipelines/armor_agent_sync'


jobs = [
  ArmorCompanySync::SyncJob.setup({}),
  ArmorAgentSync::SyncJob.setup({})
]

jobs.each do |job|
  Kiba.run(job)
end

Database.close_active_connections