class ApiValve::Middleware
  class ErrorHandling
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue Exception => e # rubocop:disable Lint/RescueException
      log_error e
      render_error(e).to_a
    end

    private

    def log_error(error)
      ApiValve.logger.error { "#{error.class}: #{error.message}" }
      ApiValve.logger.error { error.backtrace.join("\n") }
    end

    def render_error(error)
      self.class.const_get(ApiValve.error_responder).new(error).call
    end
  end
end
