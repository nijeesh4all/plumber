# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'zeitwerk'

Bundler.require(:default)

loader = Zeitwerk::Loader.new
loader.push_dir('src')
loader.push_dir('config')
loader.push_dir('lib')
loader.setup
