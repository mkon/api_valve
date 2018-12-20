module ApiValve
  class Proxy
    autoload :Builder, 'api_valve/proxy/builder'
    autoload :Runner,  'api_valve/proxy/runner'

    extend Builder

    FORWARDER_OPTIONS = %w(endpoint request response).freeze

    class_attribute :permission_handler, :request, :response
    self.permission_handler = PermissionHandler
    self.request = Forwarder::Request
    self.response = Forwarder::Response

    attr_reader :request, :forwarder, :middleware, :route_set

    alias router route_set

    def initialize(forwarder)
      @forwarder = forwarder
      @route_set = RouteSet.new
      @middleware = Middleware.new
      use Middleware::Router, route_set
    end

    def call(env)
      to_app.call(env)
    rescue ApiValve::Error::Client, ApiValve::Error::Server => e
      render_error e
    end

    delegate :add_route, to: :route_set
    delegate :use, to: :middleware

    def forward(methods, path_regexp = nil, options = {})
      options = options.with_indifferent_access
      route_set.append(methods, path_regexp, options.except(:request), proc { |request, match_data|
        forwarder.call request, {'match_data' => match_data}.merge(options[:request] || {}).with_indifferent_access
      })
    end

    def forward_all(options = {})
      forward(RouteSet::METHODS, nil, options)
    end

    def deny(methods, path_regexp = nil, with: 'Error::Forbidden')
      route_set.append(methods, path_regexp, {}, ->(*_args) { raise ApiValve.const_get(with) })
    end

    protected

    def render_error(error)
      self.class.const_get(ApiValve.error_responder).new(error).call
    end

    def to_app
      @to_app ||= @middleware.to_app(Runner.new)
    end
  end
end
