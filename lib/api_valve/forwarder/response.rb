module ApiValve
  # Wraps faraday response
  # Responsible for altering the response before it is returned

  # This class is wraps the original response. The rack_response method
  # is called by the Forwarder to build the rack response that will be
  # returned by the proxy.
  # By changing this class, we can control how the request is published
  # to the original caller

  class Forwarder::Response
    attr_reader :original_request, :original_response, :options

    WHITELISTED_HEADERS = %w(
      Cache-Control
      Content-Disposition
      Content-Type
      Location
    ).freeze

    def initialize(original_request, original_response, options = {})
      @original_request = original_request
      @original_response = original_response
      @options = options.with_indifferent_access
    end

    # Must return a rack compatible response array of status code, headers and body
    def rack_response
      [status, headers, [body]]
    end

    protected

    def permission_handler
      original_request.env['permission_handler']
    end

    private

    def status
      original_response.status
    end

    def headers
      whitelisted_headers.each_with_object({}) do |k, h|
        if k == 'Location'
          h[k] = adjust_location(original_response.headers[k])
        else
          h[k] = original_response.headers[k]
        end
      end.compact
    end

    def whitelisted_headers
      @options[:whitelisted_headers] || WHITELISTED_HEADERS
    end

    def adjust_location(location)
      return location if @options[:target_prefix] == @options[:local_prefix]

      location&.gsub(/^#{@options[:target_prefix]}/, @options[:local_prefix])
    end

    def body
      original_response.body.to_s
    end
  end
end
