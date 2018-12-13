RSpec.describe ApiValve::Router do
  subject(:router) { described_class.new }

  let(:app) do
    Class.new do
      def initialize(router)
        @router = router
      end

      def call(env)
        @router.call env
      end
    end.new(router.tap { define_routes })
  end
  let(:rack_response) { [200, {'Content-Type' => 'text/plain'}, ['OK']] }

  %w(get head post put patch delete).each do |method|
    context "when routing #{method.upcase} requests" do
      let(:route_proc) { proc { rack_response } }
      let(:define_routes) do
        router.send(method, nil, route_proc)
      end

      before do
        allow(route_proc).to receive(:call).and_call_original
      end

      it 'calls the route proc with correct args' do
        public_send(method, '/')
        expect(route_proc).to have_received(:call).with(instance_of(Rack::Request), {})
      end

      context 'when calling specific paths' do
        let(:define_routes) do
          router.send(method, %r{/exists/path}, route_proc)
          router.send(method, %r{/alsoexists/path}, ->(*_args) { rack_response })
        end

        let(:send_request) { public_send(method, '/exists/path/somewhere') }

        it 'calls block on matching paths' do
          public_send(method, '/exists/path/somewhere')
          expect(route_proc).to have_received(:call)
            .with(instance_of(Rack::Request), instance_of(MatchData))
        end

        it 'does not call block on other paths' do
          public_send(method, '/alsoexists/path/somewhere')
          expect(route_proc).not_to have_received(:call)
        end

        it 'raises ApiValve::Error::NotFound if no patch matches' do
          expect {
            public_send(method, '/doesnotexist/path/somewhere')
          }.to raise_error(ApiValve::Error::NotRouted)
        end
      end
    end
  end

  describe '#unshift' do
    let(:define_routes) do
      router.get %r{^/start}, proc1
    end
    let(:proc1) { proc { rack_response } }
    let(:proc2) { proc { rack_response } }

    before do
      [proc1, proc2].each { |pr| allow(pr).to receive(:call).and_call_original }
    end

    it 'adds the route the the front' do
      router.unshift(:get, %r{^/start}, proc2)
      get '/start'
      expect(proc1).not_to have_received(:call)
      expect(proc2).to have_received(:call)
    end
  end
end
