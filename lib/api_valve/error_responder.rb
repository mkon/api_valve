module ApiValve
  class ErrorResponder
    def initialize(error)
      @error = error
    end

    def call
      Rack::Response[
        status,
        {'Content-Type' => 'application/vnd.api+json'},
        JSON.generate({errors: [json_error]}, mode: :compat)
      ]
    end

    private

    def status
      status = @error.try(:http_status)
      return status if status.is_a?(Integer)

      Rack::Utils::SYMBOL_TO_STATUS_CODE[status] || 500
    end

    def json_error
      {
        status: status.to_s,
        code:   json_code,
        title:  json_title,
        detail: json_detail,
        meta:   json_meta
      }.compact
    end

    def json_code
      @error.try(:code) || @error.class.name.demodulize.underscore
    end

    def json_title
      @error.try(:title) || Rack::Utils::HTTP_STATUS_CODES[status]
    end

    def json_detail
      return if json_title == @error.message
      return if @error.message == @error.class.name

      @error.message
    end

    def json_meta
      (@error.try(:to_hash).presence || {}).merge(
        backtrace: ApiValve.expose_backtraces ? @error.backtrace : nil
      ).compact.presence
    end
  end
end
