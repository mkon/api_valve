module ApiValve
  module Middleware
    class ErrorHandling
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      rescue Exception => e # rubocop:disable Lint/RescueException
        log_error e
        ErrorResponder.new(e).call
      end

      private

      def log_error(error)
        ApiValve.logger.error { "#{error.class}: #{error.message}" }
        ApiValve.logger.error { error.backtrace.join("\n") }
      end
    end
  end
end
