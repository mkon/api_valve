require 'active_support/core_ext/hash'
require 'active_support/core_ext/module'
require 'faraday'

module ApiValve
  autoload :Forwarder, 'api_valve/forwarder'
  autoload :Proxy,     'api_valve/proxy'
  autoload :Router,    'api_valve/router'

  module Error
    EndpointNotFound = Class.new(RuntimeError)
    Forbidden = Class.new(RuntimeError)
  end
end
