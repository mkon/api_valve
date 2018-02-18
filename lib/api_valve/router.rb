module ApiValve
  class Router
    METHODS = %i(get post put patch delete head).freeze

    Route = Struct.new(:regexp, :block) do
      delegate :call, to: :block

      def match(path_info)
        return {} if regexp.nil? # return empty 'match data' on catch all
        regexp.match(path_info)
      end
    end

    def initialize
      reset_routes
    end

    def call(env)
      match Rack::Request.new(env)
    end

    def delete(path = nil, callee = nil)
      add_route :delete, path, callee || Proc.new
    end

    def get(path = nil, callee = nil)
      add_route :get, path, callee || Proc.new
    end

    def head(path = nil, callee = nil)
      add_route :head, path, callee || Proc.new
    end

    def patch(path = nil, callee = nil)
      add_route :patch, path, callee || Proc.new
    end

    def post(path = nil, callee = nil)
      add_route :post, path, callee || Proc.new
    end

    def put(path = nil, callee = nil)
      add_route :put, path, callee || Proc.new
    end

    def any(path = nil, callee = nil)
      add_route METHODS, path, callee || Proc.new
    end

    def reset_routes
      @routes = Hash[METHODS.map { |v| [v, []] }].freeze
    end

    private

    def add_route(methods, regexp, callee)
      Array.wrap(methods).each do |method|
        @routes[method] << Route.new(regexp, callee)
      end
    end

    def match(request)
      # For security reasons do not allow URLs that could break out of the proxy namespace on the
      # server. Preferably an nxing/apache rewrite will kill these URLs before they hit us
      raise 'URL not supported' if request.path_info.include?('/../')
      @routes && @routes[request.request_method.downcase.to_sym].each do |route|
        if match_data = route.match(request.path_info)
          return route.call request, match_data
        end
      end
      raise Error::EndpointNotFound
    end
  end
end
