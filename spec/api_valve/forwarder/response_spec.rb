RSpec.describe ApiValve::Forwarder::Response do
  subject(:response) { described_class.new(original_request, original_response, options) }

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
  let(:original_response) { instance_double(Faraday::Response, headers: response_headers, status: 301, body: nil) }
  let(:response_headers) do
    {'Location' => '/remote-prefix/see/other/path'}
  end
  let(:rack_response) { response.rack_response }
  let(:headers) { rack_response[1] }

  describe 'Location header' do
    subject { headers['Location'] }

    context 'when both remote and local have a prefix' do
      let(:options) do
        {
          target_prefix: '/remote-prefix',
          local_prefix:  '/proxy-prefix'
        }
      end

      it { is_expected.to eq '/proxy-prefix/see/other/path' }
    end

    context 'when only remote has a prefix' do
      let(:options) do
        {
          target_prefix: '/remote-prefix',
          local_prefix:  ''
        }
      end

      it { is_expected.to eq '/see/other/path' }
    end

    context 'when only local has a prefix' do
      let(:options) do
        {
          target_prefix: '',
          local_prefix:  '/proxy-prefix'
        }
      end
      let(:response_headers) do
        {'Location' => '/see/other/path'}
      end

      it { is_expected.to eq '/proxy-prefix/see/other/path' }
    end
  end
end
