module ApiValve
  # Wraps original request
  # Responsible for altering the request before it is forwarded
  class Forwarder::Request
    attr_reader :original_request, :options

    WHITELISTED_HEADERS = %w(
      Accept
      Content-Type
      User-Agent
    ).freeze
    NOT_PREFIXED_HEADERS = %w(
      Content-Length
      Content-Type
    ).freeze

    def initialize(original_request, options = {})
      @original_request = original_request
      @options = options
    end

    def method
      @method ||= original_request.request_method.downcase.to_sym
    end

    def path
      path = options['endpoint'] || ''
      if pattern = options['path']
        path += pattern % options.dig('match_data').named_captures.symbolize_keys
      else
        path += original_request.path_info
      end
      path.gsub(%r{^/}, '')
    end

    def headers
      WHITELISTED_HEADERS.each_with_object({}) do |key, h|
        h[key] = header(key)
      end.merge('X-Request-Id' => Thread.current[:request_id]).compact
    end

    def header(name)
      name = "HTTP_#{name}" unless NOT_PREFIXED_HEADERS.include? name
      name = name.upcase.tr('-', '_')
      original_request.get_header(name)
    end

    def body
      return unless %i(put post patch).include? method
      original_request.body.read
    end

    def url_params
      return unless original_request.query_string.present?
      @url_params ||= Rack::Utils.parse_nested_query(original_request.query_string)
    end
  end
end
