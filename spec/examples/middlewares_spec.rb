RSpec.describe 'Middleware example', type: :feature do
  let(:builder) { example_app 'middleware' }
  let(:app) { builder[0] }

  before do
    stub_request(:get, %r{^https://jsonplaceholder.typicode.com})
      .to_return(status: 204, headers: {'Content-Type' => 'application/json'})
  end

  it 'correctly runs the middleware' do
    get '/posts/1'
    expect(last_response.headers['Middlewares']).to eq %w(one two).to_json
  end
end
