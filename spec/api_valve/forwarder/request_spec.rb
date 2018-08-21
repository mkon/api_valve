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
      'REMOTE_ADDR'            => '10.0.0.21',
      'REQUEST_METHOD'         => 'GET',
      'QUERY_STRING'           => 'foo=bar&array[]=1&array[]=2',
      'HTTP_X_FORWARDED_FOR'   => '212.122.121.211',
      'HTTP_X_FORWARDED_HOST'  => 'api.example.com',
      'HTTP_X_FORWARDED_PORT'  => '443',
      'HTTP_X_FORWARDED_PROTO' => 'https',
      'HTTP_USER_AGENT'        => 'Faraday',
      'HTTP_OTHER_HEADER'      => 'Ignored'
    }
  end

  describe '#check_permissions!' do
    subject { -> { request.check_permissions! } }

    let(:permission_handler) do
      instance_double(ApiValve::Forwarder::PermissionHandler, check_permissions!: true)
    end

    before do
      allow(ApiValve::Forwarder::PermissionHandler).to receive(:instance)
        .and_return(permission_handler)
    end

    it 'correctly instanciates the PermissionHandler' do
      subject.call
      expect(ApiValve::Forwarder::PermissionHandler).to have_received(:instance)
        .with(original_request, resource: 'foo')
    end

    context 'when the permission handler allows it' do
      it { expect(subject.call).to eq true }
    end

    context 'when the permission handler disallows it' do
      before do
        allow(permission_handler).to receive(:check_permissions!)
          .and_raise(ApiValve::Forwarder::PermissionHandler::InsufficientPermissions)
      end

      it { is_expected.to raise_error(ApiValve::Forwarder::PermissionHandler::InsufficientPermissions) }
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
        'User-Agent'        => 'Faraday',
        'X-Forwarded-For'   => '212.122.121.211, 10.0.0.21',
        'X-Forwarded-Host'  => 'api.example.com',
        'X-Forwarded-Port'  => '443',
        'X-Forwarded-Proto' => 'https'
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
