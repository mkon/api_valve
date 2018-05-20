module ApiValve
  class Forwarder
    autoload :Request,  'api_valve/forwarder/request'
    autoload :Response, 'api_valve/forwarder/response'

    include Benchmarking

    def initialize(options = {})
      @options = options.with_indifferent_access
    end

    def call(original_request, local_options = {})
      request = request_klass.new(original_request, request_options.deep_merge(local_options))
      response_klass.new(original_request, run_request(request), response_options).rack_response
    end

    private

    def request_klass
      request_options[:klass] || Request
    end

    def request_options
      (@options[:request] || {}).merge(@options[:permission_handler] || {})
    end

    def response_klass
      response_options[:klass] || Response
    end

    def response_options
      (@options[:response] || {}).merge(@options[:permission_handler] || {})
    end

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

    # Enforce trailing slash
    def endpoint
      @endpoint ||= File.join(@options[:endpoint], '')
    end
  end
end
