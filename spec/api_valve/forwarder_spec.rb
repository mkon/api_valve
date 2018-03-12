RSpec.describe ApiValve::Forwarder do
  subject(:forwarder) { described_class.new(options) }

  let(:request_klass) { Class.new(ApiValve::Forwarder::Request) }
  let(:request_klass_instance) do
    instance_double(
      request_klass,
      method: :get,
      path: 'some/path/abc',
      url_params: {'foo' => 'bar'},
      body: '',
      headers: {}
    )
  end
  let(:response_klass) { Class.new(ApiValve::Forwarder::Response) }
  let(:response_klass_instance) do
    instance_double(
      response_klass,
      rack_response: rack_response
    )
  end
  let(:rack_response) { [200, {}, ['OK']] }
  let(:options) do
    {
      endpoint: 'http://host/api',
      request_klass: request_klass,
      response_klass: response_klass
    }
  end
  let(:original_request) do
    instance_double(Rack::Request)
  end

  before do
    stub_request(:get, %r{^http://host/api/}).to_return(status: 204)
    allow(request_klass).to receive(:new).and_return(request_klass_instance)
    allow(response_klass).to receive(:new).and_return(response_klass_instance)
  end

  describe '#call' do
    subject { forwarder.call(original_request, options) }

    it 'correctly instantiates the request' do
      subject
      expect(request_klass).to have_received(:new).with(original_request, options)
    end

    it { is_expected.to have_requested(:get, 'http://host/api/some/path/abc?foo=bar') }

    it { is_expected.to eq rack_response }
  end
end
