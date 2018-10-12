# Supress default rackup logging middleware
#\ --quiet

require 'api_valve'

class TransactionsRequest < ApiValve::Forwarder::Request
  def path
    'transactions'
  end

  def headers
    super.merge('Account-Id' => options[:account_id])
  end
end

app = Rack::Builder.new do
  use ApiValve::Middleware::ErrorHandling
  use ApiValve::Middleware::Logging

  proxy = ApiValve::Proxy.build(endpoint: 'http://api.host/api', routes: []) do
    router.get %r{^/accounts/(\d+)/transactions$} do |request, match_data|
      forwarder.call request, klass: TransactionsRequest, account_id: match_data[1]
    end
  end

  run proxy
end

run app
