module ApiValve
  class ErrorResponder
    def initialize(error)
      @error = error
    end

    def call
      [
        status,
        {'Content-Type' => 'application/json'},
        [MultiJson.dump({errors: [json_error]}, mode: :compat)]
      ]
    end

    private

    def status
      status = @error.try(:http_status)
      return status if status&.is_a?(Integer)
      Rack::Utils::SYMBOL_TO_STATUS_CODE[status] || 500
    end

    def json_error
      {
        status: status,
        code: json_code,
        detail: json_detail,
        meta: json_meta
      }.compact
    end

    def json_code
      @error.try(:code) || Rack::Utils::HTTP_STATUS_CODES[status]
    end

    def json_detail
      @error.message != @error.class.to_s ? @error.message : nil
    end

    def json_meta
      (@error.try(:to_hash).presence || {}).merge(
        backtrace: ApiValve.expose_backtraces ? json_backtrace : nil
      ).compact.presence
    end
  end
end
