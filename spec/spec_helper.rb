ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'
Bundler.require :default, 'test'

require 'json_spec'

require 'rack/test'
require 'timecop'

require 'webmock/rspec'
WebMock.disable_net_connect!

require 'simplecov'
SimpleCov.start do
  add_filter '/spec'
end
SimpleCov.minimum_coverage 90

module RSpecMixin
  include Rack::Test::Methods
end

require_relative 'support/helper'

ApiValve.logger = ActiveSupport::TaggedLogging.new(Logger.new('/dev/null'))

RSpec.configure do |config|
  config.include RSpecMixin
  config.include Helper
end
