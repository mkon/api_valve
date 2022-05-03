require 'api_valve'

app = Rack::Builder.new do
  use ApiValve::Middleware::ErrorHandling
  use ApiValve::Middleware::Logging

  proxy = ApiValve::Proxy.build(endpoint: 'https://jsonplaceholder.typicode.com') do
    router.unshift :get, %r{^/aggregated$} do |request|
      threads = (1..5).map do |i|
        Thread.new { forwarder.call request, 'path' => "posts/#{i}" }
      end
      threads.each(&:join)
      body = threads.map(&:value).map do |rack_response|
        JSON.parse(rack_response[2].first)
      end.to_json
      [200, {'Content-Type' => 'application/json'}, [body]]
    end
  end

  run proxy
end

run app
