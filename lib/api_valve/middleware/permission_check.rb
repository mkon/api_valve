class ApiValve::Middleware
  class PermissionCheck
    def initialize(app, options = {})
      @app = app
      @options = options
    end

    def call(env)
      env['permission_handler'] = @handler
      if handler(env).allowed?
        @app.call(env)
      else
        message = handler(env).message
        ApiValve.logger.debug { message }
        render_error ApiValve::Error::Forbidden.new message
      end
    end

    private

    def handler(env)
      env['permission_handler'] ||= handler_klass.new(
        env,
        @options.merge(env['api_valve.router.route'].options[:permission_handler] || {})
      )
    end

    def handler_klass
      @options[:klass] || ApiValve::PermissionHandler
    end

    def render_error(error)
      self.class.const_get(ApiValve.error_responder).new(error).call
    end
  end
end
