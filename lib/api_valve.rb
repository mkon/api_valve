require 'active_support/callbacks'
require 'active_support/configurable'
require 'active_support/core_ext/class'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/object'
require 'active_support/core_ext/module'
require 'active_support/json'
require 'active_support/notifications'
require 'active_support/rescuable'
require 'benchmark'
require 'faraday'
require 'multi_json'
require 'logger'

module ApiValve
  autoload :Benchmarking,      'api_valve/benchmarking'
  autoload :Cascade,           'api_valve/cascade'
  autoload :Error,             'api_valve/error'
  autoload :ErrorResponder,    'api_valve/error_responder'
  autoload :Forwarder,         'api_valve/forwarder'
  autoload :Middleware,        'api_valve/middleware'
  autoload :Logger,            'api_valve/logger'
  autoload :PermissionHandler, 'api_valve/permission_handler'
  autoload :Proxy,             'api_valve/proxy'
  autoload :RouteSet,          'api_valve/route_set'

  include ActiveSupport::Configurable

  config_accessor :logger do
    Logger.new(STDOUT)
  end

  config_accessor :error_responder do
    'ApiValve::ErrorResponder'
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
