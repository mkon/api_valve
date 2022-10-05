RSpec.describe ApiValve::Forwarder::Response do
  subject(:response) { described_class.new(original_request, original_response, options) }

  let(:original_request) { Rack::Request.new(env) }
  let(:env) do
    {
      'REMOTE_ADDR'            => '10.0.0.21',
      'REQUEST_METHOD'         => 'GET',
      'QUERY_STRING'           => 'foo=bar&array[]=1&array[]=2',
      'HTTP_X_FORWARDED_FOR'   => '212.122.121.211',
      'HTTP_X_FORWARDED_HOST'  => host,
      'HTTP_X_FORWARDED_PORT'  => '443',
      'HTTP_X_FORWARDED_PROTO' => 'https',
      'HTTP_USER_AGENT'        => 'Faraday',
      'HTTP_OTHER_HEADER'      => 'Ignored'
    }
  end
  let(:faraday_env) do
    {
      response_headers: response_headers,
      status:           301,
      response_body:    nil,
      url:              URI.join("https://#{host}", *[remote_prefix.presence, remote_path].compact)
    }
  end
  let(:host) { 'api.example.com' }
  let(:local_prefix) { '/proxy-prefix' }
  let(:location) { nil }
  let(:options) do
    {
      target_prefix: remote_prefix,
      local_prefix:  local_prefix
    }
  end
  let(:original_response) { Faraday::Response.new(faraday_env) }
  let(:remote_prefix) { '/remote-prefix' }
  let(:remote_path) { 'remote-path' }
  let(:response_headers) do
    {'Location' => location.presence}.compact
  end
  let(:rack_response) { response.rack_response }

  describe 'Location header' do
    subject { rack_response.location }

    context 'when both remote and local have a prefix' do
      let(:location) { '/remote-prefix/original-redirect' }
      let(:local_prefix) { '/proxy-prefix' }
      let(:remote_prefix) { '/remote-prefix' }

      it { is_expected.to eq '/proxy-prefix/original-redirect' }
    end

    context 'when only remote has a prefix' do
      let(:location) { '/remote-prefix/original-redirect' }
      let(:local_prefix) { '' }
      let(:remote_prefix) { '/remote-prefix' }

      it { is_expected.to eq '/original-redirect' }
    end

    context 'when only local has a prefix' do
      let(:location) { '/original-redirect' }
      let(:local_prefix) { '/local-prefix' }
      let(:remote_prefix) { '' }

      it { is_expected.to eq '/local-prefix/original-redirect' }
    end

    context 'when neither has a prefix' do
      let(:location) { '/original-redirect' }
      let(:local_prefix) { '' }
      let(:remote_prefix) { '' }

      it { is_expected.to eq location }
    end

    context 'when it points to a different host' do
      let(:location) { 'https://otherhost.com/original-redirect' }
      let(:local_prefix) { '/proxy-prefix' }
      let(:remote_prefix) { '/remote-prefix' }

      it { is_expected.to eq location }
    end
  end
end
