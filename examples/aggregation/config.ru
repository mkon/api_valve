require 'api_valve'
require 'byebug'

app = Rack::Builder.new do
  use ApiValve::Middleware::ErrorHandling
  use ApiValve::Middleware::Logging

  proxy = ApiValve::Proxy.build(endpoint: 'https://jsonplaceholder.typicode.com') do
    router.unshift :get, %r{^/aggregated$} do |request|
      threads = (1..5).map do |i|
        Thread.new { forwarder.call request, 'path' => "posts/#{i}" }
      end
      body = threads.map(&:value).map do |rack_response|
        JSON.parse(rack_response.body.first)
      end.to_json
      Rack::Response.new(body, 200, {'Content-Type' => 'application/json'})
    end
  end

  run proxy
end

run app
