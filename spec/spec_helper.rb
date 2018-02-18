ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'
Bundler.require :default, 'test'

require 'rack/test'
require 'timecop'

require 'webmock/rspec'
WebMock.disable_net_connect!

require 'simplecov'
SimpleCov.start

module RSpecMixin
  include Rack::Test::Methods
end

RSpec.configure { |c| c.include RSpecMixin }
