module ApiValve
  # Wraps faraday response
  # Responsible for altering the response before it is returned
  class Forwarder::Response
    include Forwarder::PermissionHandler::RequestIntegration

    attr_reader :original_request, :original_response

    WHITELISTED_HEADERS = %w(
      Content-Type
      Cache-Control
      Location
    ).freeze

    def initialize(original_request, original_response, options = {})
      @original_request = original_request
      @original_response = original_response
      @options = options.with_indifferent_access
    end

    def rack_response
      [status, headers, [body]]
    end

    private

    def status
      original_response.status
    end

    def headers
      WHITELISTED_HEADERS.each_with_object({}) do |k, h|
        h[k] = original_response.headers[k]
      end.compact
    end

    def body
      original_response.body.to_s
    end
  end
end
