module ApiValve
  class Proxy
    FORWARDER_OPTIONS = %w(endpoint).freeze

    class << self
      def from_yaml(file_path)
        from_config YAML.load_file(file_path)
      end

      def from_config(config)
        forwarder = Forwarder.new(config.slice(*FORWARDER_OPTIONS))
        new(forwarder).tap { |proxy| proxy.build_routes_from_config config }
      end
    end

    attr_reader :forwarder, :router

    def initialize(forwarder)
      @forwarder = forwarder
      @router = Router.new
    end

    delegate :add_route, :call, to: :router

    def build_routes_from_config(config)
      config['routes'].each do |route_config|
        route_from_config route_config
      end
      forward_all
    end

    def forward(methods, regexp = nil, config = {})
      Array.wrap(methods).each do |method|
        router.public_send(method, regexp, proc { |request, match_data|
          forwarder.call request, {'match_data' => match_data}.merge(config)
        })
      end
    end

    def forward_all
      router.any do |request, match_data|
        forwarder.call request, 'match_data' => match_data
      end
    end

    private

    def route_from_config(route_config)
      router.public_send route_config['method'].downcase, route_config['path'] do |req, match_data|
        raise ApiValve.const_get(route_config['raise']) if route_config['raise']
        forwarder.call req, {'match_data' => match_data}.merge(route_config['request'])
      end
    end
  end
end
