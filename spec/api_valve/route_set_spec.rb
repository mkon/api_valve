RSpec.describe ApiValve::RouteSet do
  subject(:route_set) { described_class.new }

  let(:rack_response) { [200, {'Content-Type' => 'text/plain'}, ['OK']] }
  let(:route_proc) { double(Proc, call: rack_response) } # rubocop:disable RSpec/VerifiedDoubles

  before { define_routes }

  %w(get head post put patch delete).each do |method|
    context "when routing #{method.upcase} requests" do
      let(:define_routes) do
        route_set.send(method, nil, {}, route_proc)
      end
      let(:env) do
        {
          'PATH_INFO'      => '/',
          'REQUEST_METHOD' => method
        }
      end

      it 'returns route and empty match_data' do
        route, match_data = subject.match(env)
        expect(route.call).to eq(rack_response)
        expect(match_data).to eq({})
      end

      context 'when calling specific paths' do
        let(:define_routes) do
          route_set.send(method, %r{/exists/path}, {}, route_proc)
          route_set.send(method, %r{/alsoexists/path}, {}, ->(*_args) { [204, {}, []] })
        end
        let(:env) do
          {
            'PATH_INFO'      => '/exists/path/somewhere',
            'REQUEST_METHOD' => method
          }
        end

        it 'returns route and populated match_data' do
          route, match_data = subject.match(env)
          expect(route.call).to eq(rack_response)
          expect(match_data).to be_a(MatchData)
          expect(match_data[0]).to eq '/exists/path'
        end

        it 'raises ApiValve::Error::NotFound if no patch matches' do
          expect {
            subject.match(env.merge('PATH_INFO' => '/notexists'))
          }.to raise_error(ApiValve::Error::NotRouted)
        end
      end
    end
  end

  describe '#unshift' do
    let(:define_routes) do
      route_set.get %r{^/start}, {}, proc1
    end
    let(:proc1) { proc { rack_response } }
    let(:proc2) { proc { rack_response } }
    let(:env) do
      {
        'PATH_INFO'      => '/start',
        'REQUEST_METHOD' => 'get'
      }
    end

    before do
      [proc1, proc2].each { |pr| allow(pr).to receive(:call).and_call_original }
    end

    it 'adds the route the the front' do
      route_set.unshift(:get, %r{^/start}, {}, proc2)
      route, _match_data = route_set.match(env)
      route.call
      expect(proc1).not_to have_received(:call)
      expect(proc2).to have_received(:call)
    end
  end
end
