require 'api_valve'

class MyPermissions < ApiValve::PermissionHandler
  def allowed?
    env['HTTP_AUTHORIZATION'] == 'Bearer my-api-token'
  end
end

app = Rack::Builder.new do
  use ApiValve::Middleware::Logging

  map '/api' do
    run ApiValve::Proxy.from_hash(
      endpoint:           'http://api.host/api/',
      permission_handler: {
        klass: MyPermissions
      }
    )
  end
end

run app
