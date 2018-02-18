RSpec.describe ApiValve::Proxy do
  subject { described_class.new(forwarder) }

  let(:forwarder) { ApiValve::Forwarder.new(endpoint: 'http://host/api') }

  describe '.from_yaml' do
    before do
      stub_request(:get, %r{^http://hello/api/}).to_return(status: 204)
      stub_request(:get, %r{^http://outside/api/}).to_return(status: 204)
    end

    let(:yaml_path) do
      Pathname.new(File.expand_path(__FILE__)).join('..', '..', 'fixtures', 'example.yml')
    end
    let(:app) { described_class.from_yaml(yaml_path) }

    it 'can read yaml' do
      get '/hello/you'
      expect(last_response).to be_no_content
      expect(WebMock).to have_requested(:get, 'http://hello/api/you')
    end

    it 'can proxy url parmeters' do
      get '/something?foo=bar'
      expect(last_response).to be_no_content
      expect(WebMock).to have_requested(:get, 'http://hello/api/something?foo=bar')
    end

    it 'can do other endpoints' do
      get '/outside/something'
      expect(last_response).to be_no_content
      expect(WebMock).to have_requested(:get, 'http://outside/api/something')
    end

    it 'does forbidden' do
      expect { post '/' }.to raise_error(ApiValve::Error::Forbidden)
      expect(WebMock).not_to have_requested(:get, %r{^http://hello/api/})
    end
  end

  %i(patch post put).each do |method|
    context "when forwarding #{method.to_s.upcase} requests" do
      let(:app) do
        subject.tap do |s|
          s.forward method
        end
      end

      before do
        stub_request(method, %r{^http://host/api/}).to_return(status: 204)
      end

      it 'correctly forwards the request' do
        header 'Content-Type', 'application/json'
        public_send method, '/some/path', '{"foo":"bar"}'
        expect(WebMock).to have_requested(method, 'http://host/api/some/path')
          .with(body: '{"foo":"bar"}', headers: {'Content-Type' => 'application/json'})
      end
    end
  end

  %i(get delete head).each do |method|
    context "when forwarding #{method.to_s.upcase} requests" do
      let(:app) do
        subject.tap do |s|
          s.forward method
        end
      end

      before do
        stub_request(method, %r{^http://host/api/}).to_return(status: 204)
      end

      it 'correctly forwards the request' do
        header 'Accept', 'application/json'
        public_send method, '/some/path'
        expect(WebMock).to have_requested(method, 'http://host/api/some/path')
          .with(headers: {'Accept' => 'application/json'})
      end
    end
  end
end
