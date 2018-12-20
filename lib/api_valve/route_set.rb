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

    def delete(path = nil, options = {}, prok = nil)
      push :delete, path, options, prok || Proc.new
    end

    def get(path = nil, options = {}, prok = nil)
      push :get, path, options, prok || Proc.new
    end

    def head(path = nil, options = {}, prok = nil)
      push :head, path, options, prok || Proc.new
    end

    def patch(path = nil, options = {}, prok = nil)
      push :patch, path, options, prok || Proc.new
    end

    def post(path = nil, options = {}, prok = nil)
      push :post, path, options, prok || Proc.new
    end

    def put(path = nil, options = {}, prok = nil)
      push :put, path, options, prok || Proc.new
    end

    def any(path = nil, options = {}, prok = nil)
      append METHODS, path, options, prok || Proc.new
    end

    def push(methods, regexp, options = {}, prok = nil)
      add_route :push, methods, regexp, options, prok || Proc.new
    end

    alias append push

    def unshift(methods, regexp = nil, options = {}, prok = nil)
      add_route :unshift, methods, regexp, options, prok || Proc.new
    end

    def reset_routes
      @routes = Hash[METHODS.map { |v| [v, []] }].with_indifferent_access.freeze
    end

    private

    def add_route(how, methods, regexp, options, prok)
      methods = METHODS if methods.to_s == 'any'
      Array.wrap(methods).each do |method|
        @routes[method].public_send how, Route.new(regexp, options, prok)
      end
    end
  end
end
