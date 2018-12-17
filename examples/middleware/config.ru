# Supress default rackup logging middleware
#\ --quiet

require 'api_valve'
require 'byebug'

class MyMiddleware
  def initialize(app, arg)
    @app = app
    @arg = arg
  end

  def call(env)
    env['middlewares'] ||= []
    env['middlewares'] << @arg
    status, headers, body = @app.call(env)
    [status, headers.merge('Middlewares' => env['middlewares'].to_json), body]
  end
end

app = Rack::Builder.new do
  use ApiValve::Middleware::ErrorHandling
  use ApiValve::Middleware::Logging

  proxy = ApiValve::Proxy.build(endpoint: 'https://jsonplaceholder.typicode.com') do
    use MyMiddleware, 'one'
    middleware.insert_before ApiValve::Middleware::Router, MyMiddleware, 'two'
  end

  run proxy
end

run app
