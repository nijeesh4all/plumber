# frozen_string_literal: true
require 'pg'
require 'yaml'
require 'erb'

class Database
  template = ERB.new File.new('config/database.yml').read
  CONFIG = YAML.load template.result(binding)

  CONNECTIONS = {}
  def self.setup(name)
    return CONNECTIONS[name] if CONNECTIONS[name]

    if CONFIG[name]
      CONNECTIONS[name] = new(CONFIG[name])
      return CONNECTIONS[name]
    end

    raise "No database configuration for '#{name}' found"
  end

  def self.close_active_connections
    CONNECTIONS.each do |name, connection|
      connection.close
      CONNECTIONS.delete(name)
    end
  end

  def initialize(config)
    @connection = PG.connect(config)
  end

  def connection
    @connection
  end

  def active?
    @connection.status == PG::Constants::CONNECTION_OK
  end

  def close
    @connection.finish
  end
end
