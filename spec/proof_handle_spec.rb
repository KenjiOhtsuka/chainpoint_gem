# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chainpoint::ProofHandle do
  let(:proof_handle) { described_class.new(uri, node_hash_id) }

  let(:uri)          { 'http://80.211.58.129' }
  let(:node_hash_id) { 'fa07e250-535f-11e9-833f-01d2112f8dc2' }

  describe '#initialize' do
    subject(:initialize!) { Chainpoint::ProofHandle.new(uri, node_hash_id) }

    context 'with nil uri' do
      let(:uri) { nil }

      it 'raises an ArgumentError' do
        expect { initialize! }.to raise_error(ArgumentError)
      end
    end

    context 'with nil node_hash_id' do
      let(:node_hash_id) { nil }

      it 'raises an ArgumentError' do
        expect { initialize! }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#proof', :vcr do
    subject(:proof) { proof_handle.proof }

    context 'with invalid hash id' do
      let(:node_hash_id) { '123' }

      it 'raises an error' do
        expect { proof }.to raise_error(ArgumentError, 'invalid request, bad hash_id')
      end
    end

    context 'when proof is not present' do
      let(:node_hash_id) { 'fa07e250-535f-11e9-833f-01d2112f8dc2' }
      it { is_expected.to be_nil }
    end

    context 'when proof is present' do
      let(:node_hash_id) { 'f9b2e480-535f-11e9-bdec-014a871086f2' }
      it { is_expected.to be_instance_of(Chainpoint::Proof) }
    end
  end

  describe '#to_h' do
    let(:node_hash_id) { '123' }

    it 'returns the proof handle data' do
      expect(proof_handle.to_h).to eq(uri: proof_handle.uri, node_hash_id: node_hash_id)
    end
  end
end
