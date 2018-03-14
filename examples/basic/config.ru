require 'api_valve'

app = Rack::Builder.new do
  map '/api' do
    run ApiValve::Proxy.from_hash(endpoint: 'http://api.host/api/')
  end
  map '/oauth' do
    run ApiValve::Proxy.from_hash(endpoint: 'http://auth.host/oauth/')
  end
end

run app
