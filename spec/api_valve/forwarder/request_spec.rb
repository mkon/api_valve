RSpec.describe ApiValve::Forwarder::Request do
  subject(:request) { described_class.new(original_request, options) }

  let(:options) do
    {endpoint: 'http://host/api'}
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
      'HTTP_X_REQUEST_ID'      => 'http-x-request-id-123',
      'HTTP_USER_AGENT'        => 'Faraday',
      'HTTP_OTHER_HEADER'      => 'Ignored'
    }
  end

  describe '#method' do
    subject { request.method }

    it { is_expected.to eq :get }
  end

  describe '#headers' do
    subject(:headers) { request.headers }

    it 'exposes the headers correctly' do # rubocop:disable RSpec/ExampleLength
      expect(headers).to eq(
        'User-Agent'        => 'Faraday',
        'X-Forwarded-For'   => '212.122.121.211, 10.0.0.21',
        'X-Forwarded-Host'  => 'api.example.com',
        'X-Forwarded-Port'  => '443',
        'X-Forwarded-Proto' => 'https',
        'X-Request-Id'      => 'http-x-request-id-123'
      )
    end
  end

  describe '#url_params' do
    subject(:url_params) { request.url_params }

    it 'exposes the url_params correctly' do
      expect(url_params).to eq(
        'array' => %w(1 2),
        'foo'   => 'bar'
      )
    end
  end
end
