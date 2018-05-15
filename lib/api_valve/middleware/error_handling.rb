module ApiValve
  module Middleware
    class ErrorHandling
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      rescue Exception => e # rubocop:disable Lint/RescueException
        ErrorResponder.new(e).call
      end
    end
  end
end
