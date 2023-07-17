# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app', 'controllers'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app', 'models'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app', 'helpers'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'

Bundler.require :default, ENV['RACK_ENV']

require 'sinatra'
require 'homework'
require 'active_record'
require 'faker'

require 'article'
require 'author'

Homework.logger.level = if ENV['RACK_ENV'] == 'test'
                          Logger::ERROR
                        elsif ENV['RACK_ENV'] == 'development'
                          Logger::DEBUG
                        else
                          Logger::INFO
                        end
