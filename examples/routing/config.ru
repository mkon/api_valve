require 'api_valve'

app = Rack::Builder.new do
  map '/api' do
    run ApiValve::Proxy.from_hash(
      endpoint: 'http://api.host/api/',
      routes: [
        {
          method: 'get',
          path: %r{^/prefix/(?<final_path>.*)},
          request: {path: '%{final_path}'}
        },
        {
          method: 'post',
          raise: 'Error::Forbidden'
        },
        {
          method: 'put',
          raise: 'Error::Forbidden'
        },
        {
          method: 'patch',
          raise: 'Error::Forbidden'
        }
      ]
    )
  end
end

run app
