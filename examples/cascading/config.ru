# Supress default rackup logging middleware
#\ --quiet

require 'api_valve'

app = Rack::Builder.new do
  use ApiValve::Middleware::ErrorHandling
  use ApiValve::Middleware::Logging

  drinks = ApiValve::Proxy.from_hash(
    endpoint: 'http://drinks.host/api/',
    routes:   [
      {
        method: 'any',
        path:   %r{^/beer/}
      }
    ]
  )

  foods = ApiValve::Proxy.from_hash(
    endpoint: 'http://foods.host/api/',
    routes:   [
      {
        method: 'any',
        path:   %r{^/snacks/}
      }
    ]
  )

  map '/api' do
    run ApiValve::Cascade.new(drinks, foods)
  end
end

run app
