RSpec.describe ApiValve::Error do
  let(:klass) do
    Class.new(described_class) do
      self.code = 'some_code'
      self.title = 'Some Title'
    end
  end

  describe '#code' do
    context 'when a class code is set' do
      subject(:error) { klass.new }

      it 'returns the class code' do
        expect(error.code).to eq 'some_code'
      end
    end

    context 'when an instance code is set' do
      subject(:error) { klass.new(code: 'foo') }

      it 'returns the class code' do
        expect(error.code).to eq 'foo'
      end
    end

    context 'when none is set' do
      subject(:error) { described_class.new }

      it 'returns nil' do
        expect(error.code).to be nil
      end
    end
  end

  describe '#title' do
    context 'when a class title is set' do
      subject(:error) { klass.new }

      it 'returns the class title' do
        expect(error.title).to eq 'Some Title'
      end
    end

    context 'when an instance title is set' do
      subject(:error) { klass.new(title: 'My title') }

      it 'returns the class title' do
        expect(error.title).to eq 'My title'
      end
    end

    context 'when none is set' do
      subject(:error) { described_class.new }

      it 'returns nil' do
        expect(error.title).to be nil
      end
    end
  end
end
