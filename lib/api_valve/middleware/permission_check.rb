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
        [403, {}, []]
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
  end
end
