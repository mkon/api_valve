require 'api_valve'
require 'byebug'

app = Rack::Builder.new do
  use ApiValve::Middleware::ErrorHandling
  use ApiValve::Middleware::Logging

  map '/api' do
    run ApiValve::Proxy.from_hash(
      endpoint: 'http://jsonplaceholder.typicode.com',
      routes:   [
        {
          method:  'get',
          path:    %r{^/customers/(?<path>.*)},
          request: {path: '/users/%{path}'}
        },
        {
          method: 'get'
        },
        {
          method: 'post',
          raise:  'Error::Forbidden'
        },
        {
          method: 'put',
          raise:  'Error::Forbidden'
        },
        {
          method: 'patch',
          raise:  'Error::Forbidden'
        }
      ]
    )
  end
end

run app
