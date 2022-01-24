module ApiValve
  class RouteSet
    METHODS = %i(get post put patch delete head).freeze

    Route = Struct.new(:regexp, :options, :block) do
      delegate :call, to: :block

      def match(path_info)
        return {} if regexp.nil? # return empty 'match data' on catch all

        regexp.match(path_info)
      end
    end

    def initialize
      reset_routes
    end

    def match(env)
      request = Rack::Request.new(env)

      # For security reasons do not allow URLs that could break out of the proxy namespace on the
      # server. Preferably an nxing/apache rewrite will kill these URLs before they hit us
      raise 'URL not supported' if request.path_info.include?('/../')

      match_data = nil
      route = @routes && @routes[request.request_method.downcase].find do |r|
        (match_data = r.match(request.path_info))
      end
      raise Error::NotRouted, 'Endpoint not found' unless route

      [route, match_data]
    end

    def delete(path = nil, options = {}, &block)
      push :delete, path, options, &block
    end

    def get(path = nil, options = {}, &block)
      push :get, path, options, &block
    end

    def head(path = nil, options = {}, &block)
      push :head, path, options, &block
    end

    def patch(path = nil, options = {}, &block)
      push :patch, path, options, &block
    end

    def post(path = nil, options = {}, &block)
      push :post, path, options, &block
    end

    def put(path = nil, options = {}, &block)
      push :put, path, options, &block
    end

    def any(path = nil, options = {}, &block)
      append METHODS, path, options, &block
    end

    def push(methods, regexp, options = {}, &block)
      add_route :push, methods, regexp, options, &block
    end

    alias append push

    def unshift(methods, regexp = nil, options = {}, &block)
      add_route :unshift, methods, regexp, options, &block
    end

    def reset_routes
      @routes = METHODS.to_h { |v| [v, []] }.with_indifferent_access.freeze
    end

    private

    def add_route(how, methods, regexp, options, &block)
      methods = METHODS if methods.to_s == 'any'
      Array.wrap(methods).each do |method|
        @routes[method].public_send how, Route.new(regexp, options, block)
      end
    end
  end
end
