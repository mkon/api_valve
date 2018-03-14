require 'active_support/configurable'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module'
require 'benchmark'
require 'faraday'
require 'logger'

module ApiValve
  autoload :Benchmarking, 'api_valve/benchmarking'
  autoload :Forwarder,    'api_valve/forwarder'
  autoload :Proxy,        'api_valve/proxy'
  autoload :Router,       'api_valve/router'

  include ActiveSupport::Configurable

  module Error
    EndpointNotFound = Class.new(RuntimeError)
    Forbidden = Class.new(RuntimeError)
  end

  config_accessor :logger do
    Logger.new(STDOUT)
  end

  # :nocov:
  def self.configure
    yield config
  end
  # :nocov:
end
