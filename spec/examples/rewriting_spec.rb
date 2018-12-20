RSpec.describe 'Rewriting example', type: :feature do
  let(:builder) { example_app 'rewriting' }
  let(:app) { builder[0] }

  before do
    stub_request(:get, %r{^http://api.host/api})
      .to_return(status: 204, headers: {'Content-Type' => 'application/json'})
  end

  it 'correctly rewrites the request' do
    get '/accounts/123/transactions'
    expect(WebMock).to(have_requested(:get, 'http://api.host/api/transactions')
      .with do |req|
        expect(req.headers['Account-Id']).to eq('123')
      end)
  end
end
