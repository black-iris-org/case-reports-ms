require 'rails_helper'

RSpec.describe SixDigitCipherHelper do
  let(:key) { 'a' * 32 }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('PUBLIC_ID_CIPHER_KEY').and_return(key)
  end

  describe '.scramble' do
    it 'is deterministic for a given key' do
      expect(described_class.scramble(123_456)).to eq(described_class.scramble(123_456))
    end

    it 'always returns a value within the 0..999_999 domain' do
      [0, 1, 999_999, 500_000, rand(0..999_999)].each do |n|
        expect(described_class.scramble(n)).to be_between(0, 999_999)
      end
    end

    it 'is a bijection (distinct inputs map to distinct outputs)' do
      inputs  = (0...5000).to_a
      outputs = inputs.map { |n| described_class.scramble(n) }
      expect(outputs.uniq.size).to eq(inputs.size)
    end

    it 'produces a different mapping under a different key' do
      original = described_class.scramble(123_456)

      allow(ENV).to receive(:fetch).with('PUBLIC_ID_CIPHER_KEY').and_return('b' * 32)
      expect(described_class.scramble(123_456)).not_to eq(original)
    end

    it 'raises when the cipher key is not set' do
      allow(ENV).to receive(:fetch).with('PUBLIC_ID_CIPHER_KEY').and_raise(KeyError)
      expect { described_class.scramble(123_456) }.to raise_error(KeyError)
    end
  end
end
