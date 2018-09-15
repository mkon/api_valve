RSpec.describe ApiValve::Router do
  subject(:router) { described_class.new }

  let(:app) do
    Class.new do
      def initialize(router)
        @router = router
      end

      def call(env)
        @router.call Rack::Request.new(env)
      end
    end.new(router.tap { define_routes })
  end

  %w(get head post put patch delete).each do |method|
    context "when routing #{method.upcase} requests" do
      subject(:route_proc) { instance_double(Proc, call: rack_response) }

      let(:rack_response) { [200, {'Content-Type' => 'text/plain'}, ['OK']] }
      let(:define_routes) do
        router.send(method, nil, subject)
      end

      it 'calls the route proc with correct args' do
        public_send(method, '/')
        is_expected.to have_received(:call).with(instance_of(Rack::Request), {})
      end

      context 'when calling specific paths' do
        let(:define_routes) do
          router.send(method, %r{/exists/path}, subject)
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
end
