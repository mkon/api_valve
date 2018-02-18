module ApiValve
  class Forwarder
    autoload :Request,  'api_valve/forwarder/request'
    autoload :Response, 'api_valve/forwarder/response'

    attr_accessor :endpoint

    def initialize(options = {})
      options.each do |k, v|
        public_send("#{k}=", v)
      end
    end

    def call(original_request, request_options = {})
      Response.new(run_request(original_request, request_options)).rack_response
    end

    private

    def run_request(original_request, request_options)
      request = Request.new(original_request, request_options)
      faraday.run_request(request.method, request.path, request.body, request.headers) do |req|
        req.params.update(request.url_params) if request.url_params
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
