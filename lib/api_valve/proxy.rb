require 'byebug'

module ApiValve
  class Proxy
    include ActiveSupport::Callbacks

    FORWARDER_OPTIONS = %w(endpoint request response).freeze

    define_callbacks :call

    class << self
      def from_yaml(file_path)
        from_hash YAML.load_file(file_path)
      end

      def from_hash(config)
        config = config.with_indifferent_access
        forwarder = Forwarder.new(config.slice(*FORWARDER_OPTIONS))
        new(forwarder).tap { |proxy| proxy.build_routes_from_config config }
      end
    end

    attr_reader :request, :forwarder, :router

    def initialize(forwarder)
      @forwarder = forwarder
      @router = Router.new
    end

    def call(env)
      @request = Rack::Request.new(env)
      run_callbacks(:call) { @router.call(@request) }
    rescue ApiValve::Error::Base => e
      ErrorResponder.new(e).call
    end

    delegate :add_route, to: :router

    def build_routes_from_config(config)
      config['routes']&.each do |route_config|
        method, path_regexp, request_override = *route_config.values_at('method', 'path', 'request')
        if route_config['raise']
          deny method, path_regexp, with: route_config['raise']
        else
          forward method, path_regexp, request_override
        end
      end
      forward_all
    end

    def forward(methods, path_regexp = nil, request_override = {})
      Array.wrap(methods).each do |method|
        router.public_send(method, path_regexp, proc { |request, match_data|
          forwarder.call request, {'match_data' => match_data}.merge(request_override || {})
        })
      end
    end

    def forward_all
      router.any do |request, match_data|
        forwarder.call request, 'match_data' => match_data
      end
    end

    def deny(methods, path_regexp = nil, with: 'Error::Forbidden')
      Array.wrap(methods).each do |method|
        router.public_send(method, path_regexp, ->(*_args) { raise ApiValve.const_get(with) })
      end
    end
  end
end
