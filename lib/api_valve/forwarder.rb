module ApiValve
  # This class is responsible for forwarding the HTTP request to the
  # designated endpoint. It is instantiated once per Proxy with relevant
  # options, and called from the router.

  class Forwarder
    autoload :LocationConverter,  'api_valve/forwarder/location_converter'
    autoload :Request,            'api_valve/forwarder/request'
    autoload :Response,           'api_valve/forwarder/response'

    include Benchmarking

    # Initialized with global options. Possible values are:
    # request: Options for the request wrapper. See Request#new.
    # response: Options for the response wrapper. See Response#new
    def initialize(options = {})
      @options = options.with_indifferent_access
      uri = URI(options[:endpoint])
      # Target prefix must be without trailing slash
      @target_prefix = uri.path.gsub(%r{/$}, '')
    end

    # Takes the original rack request with optional options and returns a rack response
    # Instantiates the Request and Response classes and wraps them around the original
    # request and response.
    def call(original_request, local_options = {})
      request = build_request(original_request, request_options.deep_merge(local_options))
      response = build_response(original_request, run_request(request), response_options)
      response.rack_response
    end

    private

    def build_request(original_request, options)
      klass = options[:klass] || Request
      klass.new(original_request, options)
    end

    def build_response(original_request, original_response, options)
      klass = options[:klass] || Response
      klass.new(
        original_request,
        original_response,
        options.merge(
          target_prefix: @target_prefix,
          local_prefix:  original_request.env['SCRIPT_NAME']
        )
      )
    end

    def request_options
      (@options[:request] || {})
    end

    def response_options
      (@options[:response] || {})
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
    rescue Faraday::ConnectionFailed
      raise Error::ServiceUnavailable
    end

    def log_request(request)
      ApiValve.logger.debug do
        format(
          '-> %<method>s %<endpoint>s%<path>s',
          method:   request.method.upcase,
          endpoint: endpoint,
          path:     request.path
        )
      end
    end

    def log_response(response, elapsed_time)
      ApiValve.logger.debug do
        format(
          '<- %<status>s in %<ms>dms',
          status: response.status,
          ms:     elapsed_time * 1000
        )
      end
    end

    def faraday
      @faraday ||= Faraday.new(
        url: endpoint,
        ssl: {verify: false}
      ) do |config|
        config.request :instrumentation
        config.adapter Faraday.default_adapter
      end
    end

    # Enforce trailing slash
    def endpoint
      @endpoint ||= File.join(@options[:endpoint], '')
    end
  end
end
