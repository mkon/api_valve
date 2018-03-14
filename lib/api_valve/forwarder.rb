module ApiValve
  class Forwarder
    autoload :Request,  'api_valve/forwarder/request'
    autoload :Response, 'api_valve/forwarder/response'

    include Benchmarking

    DEFAULT_OPTIONS = {
      response_klass: Response,
      request_klass: Request
    }.freeze

    attr_accessor :response_klass, :request_klass
    attr_reader :endpoint

    def initialize(options = {})
      DEFAULT_OPTIONS.merge(options).each do |k, v|
        public_send("#{k}=", v)
      end
    end

    def call(original_request, request_options = {})
      request = request_klass.new(original_request, request_options)
      response_klass.new(run_request(request)).rack_response
    end

    # Enforce trailing slash
    def endpoint=(endpoint)
      @endpoint = File.join(endpoint, '')
    end

    private

    def run_request(request)
      log_request request
      response, elapsed_time = benchmark do
        faraday.run_request(request.method, request.path, request.body, request.headers) do |req|
          req.params.update(request.url_params) if request.url_params
        end
      end
      log_response response, elapsed_time
      response
    end

    def log_request(request)
      ApiValve.logger.info do
        format(
          '-> %<method>s %<endpoint>s%<path>s',
          method: request.method.upcase,
          endpoint: endpoint,
          path: request.path
        )
      end
    end

    def log_response(response, elapsed_time)
      ApiValve.logger.info do
        format(
          '<- %<status>s in %<ms>dms',
          status: response.status,
          ms: elapsed_time * 1000
        )
      end
    end

    def faraday
      @faraday ||= Faraday.new(
        url: endpoint,
        ssl: {verify: false}
      ) do |config|
        config.adapter Faraday.default_adapter
      end
    end
  end
end
