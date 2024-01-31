# frozen_string_literal: true

require 'yaml'

# The PipelineRunner class is responsible for loading, configuring, and running data processing pipelines.
# It reads pipeline configurations from YAML files located in the './pipelines/' directory.
# Pipelines can be selectively executed based on the provided list of pipeline names.
# The class encapsulates the logic for running each pipeline, measuring execution time, and logging information.
#
# @example
#   runner = PipelineRunner.new(['pipeline1', 'pipeline2'])
#   runner.run_pipelines
class PipelineRunner
  def initialize(pipelines_to_run = PipelineRunner.all_pipeline_names)
    @pipelines_to_run = pipelines_to_run
    @logger = ::PipelineLogger.instance
  end

  def run_pipelines
    run_selected_pipelines
  end

  def self.all_pipeline_names
    load_pipeline_configurations.keys
  end

  def self.load_pipeline_configurations
    configurations = {}
    Dir.glob('./pipelines/*.yml').each do |file|
      loaded_config = YAML.load(File.read(file), symbolize_names: true)
      pipeline_name = File.basename(file, '.yml')
      configurations[pipeline_name] = loaded_config
    end

    configurations
  end

  private

  def run_selected_pipelines
    configurations = PipelineRunner.load_pipeline_configurations

    configurations.each do |pipeline_name, pipeline_config|
      run_pipeline(pipeline_name, pipeline_config) unless skip_pipeline?(pipeline_name)
    end
  end

  def run_pipeline(pipeline_name, pipeline_config)
    @logger.info "#{'=' * 50} PIPELINE LOADED #{pipeline_name} #{'=' * 50}"

    started_time = Time.now
    pipeline_factory = Pipelines::Factory.new(pipeline_config[0])
    Kiba.run(pipeline_factory.pipeline)

    @logger.info "total time to sync #{Time.now - started_time}s"
    @logger.info "#{'=' * 50} PIPELINE RAN #{pipeline_name} #{'=' * 50}"
  end

  def skip_pipeline?(pipeline_name)
    @pipelines_to_run.any? && !@pipelines_to_run.include?(pipeline_name)
  end

end
