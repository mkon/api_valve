RSpec.describe 'Middleware example', type: :feature do
  let(:builder) { example_app 'middleware' }
  let(:app) { builder[0] }

  before do
    stub_request(:get, %r{^http://api.host/api})
      .to_return(status: 204, headers: {'Content-Type' => 'application/json'})
  end

  context 'when accessing private area' do
    it 'denies request via middleware' do
      get '/private/1'
      expect(last_response.status).to eq 401
    end
  end

  context 'when accessing public area' do
    it 'let\'s the request pass through' do
      get '/public/1'
      expect(last_response.status).to eq 204
    end
  end
end
