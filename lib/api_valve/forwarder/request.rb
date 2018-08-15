module ApiValve
  # This class is wraps the original request. It's methods are called by
  # the Forwarder to make the actual request in the target endpoint.
  # So by changing the public methods in this call, we can control how the
  # request is forwarded

  class Forwarder::Request
    include Forwarder::PermissionHandler::RequestIntegration

    attr_reader :original_request, :options

    WHITELISTED_HEADERS = %w(
      Accept
      Content-Type
      User-Agent
      X-Real-IP
    ).freeze
    NOT_PREFIXED_HEADERS = %w(
      Content-Length
      Content-Type
    ).freeze

    def initialize(original_request, options = {})
      @original_request = original_request
      @options = options.with_indifferent_access
    end

    # Is the request allowed? If it returns false, Forwarder will raise Error::Forbidden
    def allowed?
      permission_handler.request_allowed?
    end

    # HTTP method to use when forwarding. Must return sym.
    # Returns original request method
    def method
      @method ||= original_request.request_method.downcase.to_sym
    end

    # URL path to use when forwarding
    def path
      path = options['endpoint'] || ''
      if pattern = options['path']
        path += pattern % options.dig('match_data').named_captures.symbolize_keys
      else
        path += original_request.path_info
      end
      # we remove leading slash so we can use endpoints with deeper folder levels
      path.gsub(%r{^/}, '')
    end

    # Returns a hash of headers to forward to the target endpoint
    # Override to control the HTTP headers that will be passed through
    def headers
      whitelisted_headers.each_with_object({}) do |key, h|
        h[key] = header(key)
      end.merge(forwarded_headers).merge(
        'X-Request-Id' => Thread.current[:request_id]
      ).compact
    end

    # Returns body to forward to the target endpoint
    # Override to control the payload that is passed through
    def body
      return unless %i(put post patch).include? method
      original_request.body.read
    end

    # Returns query params to forward to the target endpoint
    # Override to control the query parameters that can be passed through
    def url_params
      return unless original_request.query_string.present?
      @url_params ||= Rack::Utils.parse_nested_query(original_request.query_string)
    end

    private

    def forwarded_headers
      {
        'X-Forwarded-For'   => x_forwarded_for,
        'X-Forwarded-Host'  => original_request.host,
        'X-Forwarded-Port'  => original_request.port.to_s,
        'X-Forwarded-Proto' => original_request.scheme
      }
    end

    def x_forwarded_for
      (
        header('X-Forwarded-For').to_s.split(', ') << original_request.env['REMOTE_ADDR']
      ).join(', ')
    end

    def header(name)
      name = "HTTP_#{name}" unless NOT_PREFIXED_HEADERS.include? name
      name = name.upcase.tr('-', '_')
      original_request.get_header(name)
    end

    def whitelisted_headers
      @options[:whitelisted_headers] || WHITELISTED_HEADERS
    end
  end
end
