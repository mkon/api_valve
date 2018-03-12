RSpec.describe 'Building a rack application', type: :feature do
  context 'with more then one mapping' do
    let(:app) do
      Rack::Builder.new do
        map '/catch1' do
          run ApiValve::Proxy.from_hash(endpoint: 'http://catch1/api')
        end
        map '/catch2' do
          run ApiValve::Proxy.from_hash(endpoint: 'http://catch2/api')
        end
      end
    end

    before do
      stub_request(:get, %r{^http://catch1/api/}).to_return(status: 200, body: 'OK')
      stub_request(:get, %r{^http://catch2/api/}).to_return(status: 200, body: 'OK')
    end

    it 'can proxy first mapping' do
      get '/catch1/something'
      expect(last_response).to be_ok
      expect(WebMock).to have_requested(:get, 'http://catch1/api/something')
    end

    it 'can proxy second mapping' do
      get '/catch2/something'
      expect(last_response).to be_ok
      expect(WebMock).to have_requested(:get, 'http://catch2/api/something')
    end

    it 'does not catch unmapped paths' do
      get '/catch3/something'
      expect(last_response).to be_not_found
      expect(WebMock).not_to have_requested('any', 'any_host')
    end
  end
end
