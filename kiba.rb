# frozen_string_literal: true

require_relative 'config/setup'

require 'kiba'
require 'yaml'

require_relative 'pipelines/armor_company_sync'
require_relative 'pipelines/armor_agent_sync'

pipelines = YAML.load File.read('pipelines.yml')

pipelines.each do |pipeline|
  debugger
end