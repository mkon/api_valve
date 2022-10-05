RSpec.describe 'Routing example', type: :feature do
  let(:app) { example_app 'routing' }

  before do
    stub_request(:get, %r{^http://jsonplaceholder.typicode.com/users})
      .to_return(status: 204, headers: {'Content-Type' => 'application/json'})
  end

  describe "GET '/api/customers/1'" do
    it 'correctly forwards the request' do
      get '/api/customers/1'
      expect(WebMock).to(have_requested(:get, 'http://jsonplaceholder.typicode.com/users/1'))
    end
  end

  describe "GET '/api/users/2'" do
    it 'correctly forwards the request' do
      get '/api/users/2'
      expect(WebMock).to(have_requested(:get, 'http://jsonplaceholder.typicode.com/users/2'))
    end
  end
end
