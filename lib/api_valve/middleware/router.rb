class ApiValve::Middleware
  class Router
    def initialize(app, routeset)
      @app = app
      @routeset = routeset
    end

    def call(env)
      route, match_data = @routeset.match env
      env['api_valve.router.route'] = route
      env['api_valve.router.match_data'] = match_data
      @app.call(env)
    end
  end
end
