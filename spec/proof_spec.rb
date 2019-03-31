# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chainpoint::Proof do
  let(:proof) { described_class.new(proof_string) }

  describe '#decode' do
    subject { proof.decode }

    let(:data) { { 'hello' => 'World' } }
    let(:proof_string) { encode(data) }

    it { is_expected.to eq(data) }
  end

  describe '#verify', :vcr do
    subject(:verification) { proof.verify }

    before do
      allow(Chainpoint).to receive(:select_nodes).with(1).and_return(['http://212.237.35.202'])
    end

    context 'when proof does not exist' do
      let(:proof_string) { '123' }

      it { is_expected.to be_nil }
    end

    context 'when proof exists' do
      let(:proof_string) { File.read('spec/fixtures/proof.chp') }

      it 'verifies the proof' do
        expect(verification['status']).to eq('verified')
      end
    end
  end

  def encode(data)
    Base64.encode64(
      Zlib::Deflate.deflate(
        MessagePack.pack(data)
      )
    )
  end
end
