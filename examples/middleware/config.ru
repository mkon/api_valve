require 'api_valve'
require 'byebug'

class TokenPresence
  def initialize(app)
    @app = app
  end

  def call(env)
    if token_required?(env) && !token_present?(env)
      [401, {'Content-Type' => 'text/plain'}, ['Unauthorized']]
    else
      @app.call(env)
    end
  end

  private

  def token_present?(env)
    env['HTTP_AUTHORIZATION'] == 'Bearer secret-token'
  end

  def token_required?(env)
    !env['api_valve.router.route'].options[:tokenless]
  end
end

app = Rack::Builder.new do
  use ApiValve::Middleware::ErrorHandling
  use ApiValve::Middleware::Logging

  proxy = ApiValve::Proxy.build(endpoint: 'http://api.host/api', routes: []) do
    use TokenPresence

    forward 'get', %r{^/public/}, tokenless: true
    forward 'get', %r{^/private/}
  end

  run proxy
end

run app
