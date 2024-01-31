# frozen_string_literal: true

require 'pg'
require 'yaml'
require 'erb'

# The Database class encapsulates functionality for managing PostgreSQL database connections.
# It reads database configurations from the 'config/database.yml' file, using ERB for templating.
# The class ensures that only one connection is established per database configuration.
# Additionally, it provides methods to check the connection status, close active connections, and more.
#
# @example:
#   db_connection = Database.setup('armor')
#   puts "Is the connection active? #{db_connection.active?}"
#   Database.close_active_connections
class Database
  template = ERB.new File.new('config/database.yml').read
  CONFIG = YAML.load template.result(binding)

  def self.setup(database_name)
    return connections[database_name] if connections[database_name]

    if CONFIG[database_name]
      connections[database_name] = new(CONFIG[database_name])
      return connections[database_name]
    end

    raise "No database configuration for '#{database_name}' found"
  end

  def self.close_active_connections
    connections.each do |name, connection|
      connection.close if connection.active?
      connections.delete(name)
    end
  end

  attr_reader :connection

  def initialize(config)
    @connection = PG.connect(config)
  end

  def active?
    connection.status == PG::Constants::CONNECTION_OK
  end

  def close
    connection.finish
  end

  def self.connections
    @connections ||= {}
  end
end
