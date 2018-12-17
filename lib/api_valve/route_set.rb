module ApiValve
  class RouteSet
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

    def match(env)
      request = Rack::Request.new(env)

      # For security reasons do not allow URLs that could break out of the proxy namespace on the
      # server. Preferably an nxing/apache rewrite will kill these URLs before they hit us
      raise 'URL not supported' if request.path_info.include?('/../')

      match_data = nil
      route = @routes && @routes[request.request_method.downcase.to_sym].find do |r|
        (match_data = r.match(request.path_info))
      end
      raise Error::NotRouted, 'Endpoint not found' unless route

      [route, match_data]
    end

    def delete(path = nil, prok = nil)
      append :delete, path, prok || Proc.new
    end

    def get(path = nil, prok = nil)
      append :get, path, prok || Proc.new
    end

    def head(path = nil, prok = nil)
      append :head, path, prok || Proc.new
    end

    def patch(path = nil, prok = nil)
      append :patch, path, prok || Proc.new
    end

    def post(path = nil, prok = nil)
      append :post, path, prok || Proc.new
    end

    def put(path = nil, prok = nil)
      append :put, path, prok || Proc.new
    end

    def any(path = nil, prok = nil)
      append METHODS, path, prok || Proc.new
    end

    def append(methods, regexp, prok = nil)
      prok ||= Proc.new
      Array.wrap(methods).each do |method|
        @routes[method] << Route.new(regexp, prok)
      end
    end

    def unshift(methods, regexp = nil, prok = nil)
      prok ||= Proc.new
      Array.wrap(methods).each do |method|
        @routes[method].unshift Route.new(regexp, prok)
      end
    end

    def reset_routes
      @routes = Hash[METHODS.map { |v| [v, []] }].freeze
    end
  end
end
