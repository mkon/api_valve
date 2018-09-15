RSpec.describe ApiValve::Cascade do
  subject(:cascade) { described_class.new(*proxies) }

  let(:proxies) do
    [
      ApiValve::Proxy.from_hash(
        endpoint: 'http://drinks.host/api/',
        routes: [
          {
            method: 'any',
            path: %r{^/beer/}
          }
        ]
      ),
      ApiValve::Proxy.from_hash(
        endpoint: 'http://foods.host/api/',
        routes: [
          {
            method: 'any',
            path: %r{^/snacks/}
          }
        ]
      )
    ]
  end
  let(:app) { cascade }

  before do
    stub_request(:post, %r{^http://drinks.host/api/})
      .to_return(status: 201)
    stub_request(:post, %r{^http://foods.host/api/})
      .to_return(status: 201)
  end

  it 'can reach first proxy' do
    post '/beer/orders'
    expect(WebMock).to have_requested(:post, 'http://drinks.host/api/beer/orders')
    expect(WebMock).not_to have_requested(:post, %r{http://foods.host})
    expect(last_response).to be_created
  end

  it 'can reach second proxy' do
    post '/snacks/orders'
    expect(WebMock).to have_requested(:post, 'http://foods.host/api/snacks/orders')
    expect(WebMock).not_to have_requested(:post, %r{http://drinks.host})
    expect(last_response).to be_created
  end

  it 'renders not found on unrouted paths' do
    post '/water/orders'
    expect(WebMock).not_to have_requested(:post, %r{http://drinks.host})
    expect(WebMock).not_to have_requested(:post, %r{http://foods.host})
    expect(last_response).to be_not_found
    expect(last_response.body).to be_json_eql(
      <<-JSON
      {
        "errors":[
          {
            "status":"404",
            "code":"not_found",
            "title":"Not Found"
          }
        ]
      }
      JSON
    )
  end
end
