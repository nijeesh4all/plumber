# frozen_string_literal: true

require 'singleton'
require 'semantic_logger'
# simple Logger class that wraps SemanticLogger
class PipelineLogger
  include Singleton

  attr_reader :logger

  def initialize
    SemanticLogger.add_appender(io: $stdout)
    @logger = SemanticLogger['Plumber']
    SemanticLogger.default_level = :trace
  end

  def method_missing(method_name, *args, &block)
    if logger.respond_to?(method_name)
      logger.send(method_name, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    logger.respond_to?(method_name) || super
  end
end
