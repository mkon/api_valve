RSpec.describe 'Building a rack application', type: :feature do
  context 'with more then one mapping' do
    let(:app) do
      Rack::Builder.new do
        map '/catch1' do
          run ApiValve::Proxy.from_hash(endpoint: 'http://host1/api')
        end
        map '/catch2' do
          run ApiValve::Proxy.from_hash(endpoint: 'http://host2/api')
        end
        map '/catch3/prefix' do
          run ApiValve::Proxy.from_hash(endpoint: 'http://host3/api/')
        end
      end
    end

    before do
      stub_request(:get, %r{^http://host1/}).to_return(status: 200, body: 'OK')
      stub_request(:get, %r{^http://host2/}).to_return(status: 200, body: 'OK')
      stub_request(:get, %r{^http://host3/}).to_return(
        status: 301,
        headers: {'Location' => '/api/see/other/record'}
      )
    end

    it 'can proxy first mapping' do
      get '/catch1/something'
      expect(last_response).to be_ok
      expect(WebMock).to have_requested(:get, 'http://host1/api/something')
    end

    it 'can proxy second mapping' do
      get '/catch2/something'
      expect(last_response).to be_ok
      expect(WebMock).to have_requested(:get, 'http://host2/api/something')
    end

    it 'rewrites paths to match outside world' do
      get '/catch3/prefix/something'
      expect(last_response.status).to eq 301
      expect(last_response.headers['Location']).to eq '/catch3/prefix/see/other/record'
      expect(WebMock).to have_requested(:get, 'http://host3/api/something')
    end

    it 'does not catch unmapped paths' do
      get '/catch3/something'
      expect(last_response).to be_not_found
      expect(WebMock).not_to have_requested('any', 'any_host')
    end
  end
end
