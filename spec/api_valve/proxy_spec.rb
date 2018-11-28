RSpec.describe ApiValve::Proxy do
  subject { described_class.new(forwarder) }

  let(:forwarder) { ApiValve::Forwarder.new(endpoint: 'http://host/api') }

  describe '.from_yaml' do
    before do
      stub_request(:any, %r{^http://example/api/}).to_return(status: 204)
      stub_request(:get, %r{^http://outside/api/}).to_return(status: 204)
    end

    let(:yaml_path) do
      Pathname.new(File.expand_path(__FILE__)).join('..', '..', 'fixtures', 'example.yml')
    end
    let(:app) { described_class.from_yaml(File.read(yaml_path)) }

    it 'can read yaml' do
      get '/hello/you'
      expect(last_response).to be_no_content
      expect(WebMock).to have_requested(:get, 'http://example/api/you')
    end

    it 'can proxy url parmeters' do
      get '/something?foo=bar'
      expect(last_response).to be_no_content
      expect(WebMock).to have_requested(:get, 'http://example/api/something?foo=bar')
    end

    it 'can do other endpoints' do
      get '/outside/something'
      expect(last_response).to be_no_content
      expect(WebMock).to have_requested(:get, 'http://outside/api/something')
    end

    it 'does forbidden' do
      post '/'
      expect(last_response).to be_forbidden
      expect(WebMock).not_to have_requested(:get, %r{^http://example/api/})
    end

    it 'handles implicit any verbs' do
      %i(get put post patch delete head).each do |verb|
        public_send(verb, "/any/#{verb}")
        expect(last_response).to be_no_content
        expect(WebMock).to have_requested(verb, "http://example/api/via_any/#{verb}")
      end
    end
  end

  describe '.build' do
    let(:app) do
      described_class.build(endpoint: 'http://service/api') do
        router.get %r{^/foo/(\d+)/bar$} do |request, match_data|
          forwarder.call request, path: "bazz/#{match_data[1]}/foo"
        end
      end
    end

    before do
      stub_request(:get, %r{^http://service/api/}).to_return(status: 204)
    end

    it 'can be used to build a proxy' do
      expect(app).to be_a(described_class)
    end

    it 'correctly parses the block' do
      get '/foo/123/bar'
      expect(last_response).to be_no_content
      expect(WebMock).to have_requested(:get, 'http://service/api/foo/123/bar')
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
