require 'api_valve'

app = Rack::Builder.new do
  map '/api' do
    run ApiValve::Proxy.from_hash(endpoint: 'https://jsonplaceholder.typicode.com')
  end
  map '/health' do
    run ->(_env) { [200, {}, ['']] }
  end
end

run app
