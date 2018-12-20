module ApiValve
  class Proxy::Runner
    def call(env)
      env['api_valve.router.route'].call \
        Rack::Request.new(env),
        env['api_valve.router.match_data']
    end
  end
end
