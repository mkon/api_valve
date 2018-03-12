module ApiValve
  # Wraps faraday response
  # Responsible for altering the response before it is returned
  class Forwarder::Response
    attr_reader :original_response

    WHITELISTED_HEADERS = %w(
      Content-Type
      Cache-Control
    ).freeze

    def initialize(original_response)
      @original_response = original_response
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
