require 'active_support/callbacks'
require 'active_support/configurable'
require 'active_support/core_ext/class'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object'
require 'active_support/core_ext/module'
require 'active_support/json'
require 'active_support/rescuable'
require 'benchmark'
require 'faraday'
require 'multi_json'
require 'logger'

module ApiValve
  autoload :Benchmarking,   'api_valve/benchmarking'
  autoload :Error,          'api_valve/error'
  autoload :ErrorResponder, 'api_valve/error_responder'
  autoload :Forwarder,      'api_valve/forwarder'
  autoload :Logger,         'api_valve/logger'
  autoload :Proxy,          'api_valve/proxy'
  autoload :Router,         'api_valve/router'

  include ActiveSupport::Configurable

  module Middleware
    autoload :ErrorHandling, 'api_valve/middleware/error_handling'
    autoload :Logging,       'api_valve/middleware/logging'
  end

  config_accessor :logger do
    Logger.new(STDOUT)
  end

  config_accessor :expose_backtraces do
    false
  end

  config_accessor :config_paths do
    []
  end

  # :nocov:
  def self.configure
    yield config
  end
  # :nocov:
end
