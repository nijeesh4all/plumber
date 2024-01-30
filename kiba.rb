# frozen_string_literal: true

require_relative 'config/setup'

require 'kiba'
require 'yaml'

configurations = []

Dir.glob('./pipelines/*.yml').map do |file|
  loaded_config = YAML.load(File.read(file), symbolize_names: true)
  configurations += loaded_config
end

configurations.each do |pipeline_config|
  pipeline_factory = Pipelines::Factory.new(pipeline_config)
  Kiba.run(pipeline_factory.pipeline)
end