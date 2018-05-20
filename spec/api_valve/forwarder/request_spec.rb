RSpec.describe ApiValve::Forwarder::Request do
  subject(:request) { described_class.new(original_request, options) }

  let(:options) do
    {
      endpoint: 'http://host/api',
      permission_handler: {
        resource: 'foo'
      }
    }
  end
  let(:original_request) { Rack::Request.new(env) }
  let(:env) do
    {
      'REQUEST_METHOD'        => 'GET',
      'QUERY_STRING'          => 'foo=bar&array[]=1&array[]=2',
      'HTTP_X_FORWARDED_FOR'  => '127.0.0.1',
      'HTTP_X_FORWARDED_HOST' => 'api.example.com',
      'HTTP_X_FORWARDED_PORT' => '8080',
      'HTTP_USER_AGENT'       => 'Faraday',
      'HTTP_OTHER_HEADER'     => 'Ignored'
    }
  end

  describe '#allowed?' do
    subject { request.allowed? }

    let(:permission_handler) do
      instance_double(ApiValve::Forwarder::PermissionHandler, request_allowed?: allowed)
    end
    let(:allowed) { true }

    before do
      allow(ApiValve::Forwarder::PermissionHandler).to receive(:instance)
        .and_return(permission_handler)
    end

    it 'correctly instanciates the PermissionHandler' do
      subject
      expect(ApiValve::Forwarder::PermissionHandler).to have_received(:instance)
        .with(original_request, resource: 'foo')
    end

    context 'when the permission handler allows it' do
      let(:allowed) { true }

      it { is_expected.to eq true }
    end

    context 'when the permission handler disallows it' do
      let(:allowed) { false }

      it { is_expected.to eq false }
    end
  end

  describe '#method' do
    subject { request.method }

    it { is_expected.to eq :get }
  end

  describe '#headers' do
    subject { request.headers }

    it do # rubocop:disable RSpec/ExampleLength
      is_expected.to eq(
        'User-Agent'       => 'Faraday',
        'X-Forwarded-For'  => '127.0.0.1',
        'X-Forwarded-Host' => 'api.example.com',
        'X-Forwarded-Port' => '8080'
      )
    end
  end

  describe '#url_params' do
    subject { request.url_params }

    it do
      is_expected.to eq(
        'array' => %w(1 2),
        'foo'   => 'bar'
      )
    end
  end
end
