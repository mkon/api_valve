RSpec.describe 'Permissions example', type: :request do
  let(:builder) { example_app 'permissions' }
  let(:app) { builder[0] }

  before do
    stub_request(:get, %r{^http://api.host/api})
      .to_return(status: 204, headers: {'Content-Type' => 'application/json'})
  end

  context 'when providing the api token' do
    it 'allows request' do
      get '/api', {}, 'HTTP_AUTHORIZATION' => 'Bearer my-api-token'
      expect(last_response.status).to eq(204)
    end
  end

  context 'when providing the api token' do
    it 'denies request' do
      get '/api'
      expect(last_response.status).to eq(403)
      expect(last_response.body).to be_json_eql(
        {
          errors: [
            {
              code:   'forbidden',
              detail: 'Insufficient permissions',
              status: '403',
              title:  'Forbidden'
            }
          ]
        }.to_json
      )
    end
  end
end
