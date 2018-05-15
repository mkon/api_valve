require 'byebug'

module ApiValve
  class Proxy
    include ActiveSupport::Rescuable

    FORWARDER_OPTIONS = %w(endpoint).freeze

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

    attr_reader :forwarder, :router

    def initialize(forwarder)
      @forwarder = forwarder
      @router = Router.new
    end

    def call(*args)
      @router.call(*args)
    rescue ApiValve::Error::Base => e
      ErrorResponder.new(e).call
    end

    delegate :add_route, to: :router

    def build_routes_from_config(config)
      config['routes']&.each do |route_config|
        method, path_regexp, req_conf = *route_config.values_at('method', 'path', 'request')
        if route_config['raise']
          deny method, path_regexp, with: route_config['raise']
        else
          forward method, path_regexp, req_conf
        end
      end
      forward_all
    end

    def forward(methods, path_regexp = nil, config = {})
      Array.wrap(methods).each do |method|
        router.public_send(method, path_regexp, proc { |request, match_data|
          forwarder.call request, {'match_data' => match_data}.merge(config || {})
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
