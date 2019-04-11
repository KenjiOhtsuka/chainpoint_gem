# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chainpoint::Hash do
  let(:chainpoint_hash) { described_class.from_data(data) }
  let(:data) { 'Hello, World' }

  describe '.from_data' do
    it 'creates a new hash with a sha256 hash of the data' do
      expect(chainpoint_hash.hash).to eq(Digest::SHA256.hexdigest(data))
    end
  end

  describe '#proof_handles=' do
    let(:hash) { described_class.new('abcdefg') }

    it 'allows passing proof handles with string keys' do
      hash.proof_handles = [{ 'uri': 'http://1.2.3.4', 'node_hash_id': '123' }]

      expect(hash.proof_handles.size).to be(1)
    end

    it 'allows passing proof handles with symbol keys' do
      hash.proof_handles = [{ uri: 'http://1.2.3.4', node_hash_id: '123' }]
      expect(hash.proof_handles.size).to be(1)
    end
  end

  describe '#submit' do
    subject(:handles) do
      VCR.use_cassette('Chainpoint_Hash/submit') do
        chainpoint_hash.submit
      end
    end

    let(:nodes) { ['http://138.68.111.47', 'http://80.211.33.253', 'http://206.189.74.81'] }

    before { allow(Chainpoint).to receive(:select_nodes).with(3).and_return(nodes) }

    it 'submits three times' do
      expect(handles.size).to eq(3)
    end

    it 'returns hash representations of the proof handles' do
      handles.each_with_index do |handle, index|
        expect(handle[:uri]).to eq(nodes[index])
        expect(handle[:node_hash_id]).not_to be_nil
      end
    end
  end

  describe '#proof' do
    subject { chainpoint_hash.proof(anchor_type) }

    let(:chainpoint_hash) do
      Chainpoint::Hash.new(
        'hash',
        proof_handles: [{ node_hash_id: 'node-hash-id', uri: 'http://1.1.1.1' }]
      )
    end

    let(:proof_handle) { chainpoint_hash.proof_handles.first }
    let(:anchor_type)  { nil }

    before { allow(proof_handle).to receive(:proof).and_return(proof) }

    context 'when no proof is present' do
      let(:proof) { nil }
      it { is_expected.to be_nil }
    end

    context 'when proof is present' do
      let(:proof) { Chainpoint::Proof.new('PROOFSTRING') }

      it { is_expected.to be(proof) }
    end

    context 'with anchor type' do
      let(:proof) { Chainpoint::Proof.new('PROOFSTRING', '123', ['cal']) }

      context 'and no proof with complete type is present' do
        let(:anchor_type) { 'btc' }

        it { is_expected.to be_nil }
      end

      context 'and proof with complete type is present' do
        let(:anchor_type) { 'cal' }

        it { is_expected.to be(proof) }
      end
    end
  end

  describe '#to_h' do
    subject(:hash) { chainpoint_hash.to_h }

    it 'returns a hash representation of the object' do
      expect(hash[:hash]).to eq(chainpoint_hash.hash)
      expect(hash[:proof_handles]).to eq(chainpoint_hash.proof_handles)
    end
  end
end
