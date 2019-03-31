# frozen_string_literal: true

require 'digest'

module Chainpoint
  class Hash
    NUM_SERVERS = 3

    attr_reader :hash, :proof_handles

    def self.from_data(data)
      new(Digest::SHA256.hexdigest(data))
    end

    def initialize(hash, proof_handles: [])
      @hash = hash
      @proof_handles =
        proof_handles.map do |data|
          ProofHandle.new(data[:uri], data[:node_hash_id])
        end
    end

    def submit
      @proof_handles = Chainpoint.select_nodes(NUM_SERVERS).flat_map do |uri|
        post_hash(uri, hash)['hashes'].map do |hash|
          Chainpoint::ProofHandle.new(uri, hash['hash_id_node'])
        end
      end

      @proof_handles.map(&:to_h)
    end

    def proof(anchor_type = nil)
      return nil unless @proof_handles.any?

      proofs = @proof_handles.map(&:proof).compact

      anchor_type ? proofs.find { |p| p.anchors_complete.include?(anchor_type) } : proofs.first
    end

    def to_h
      {
        hash: @hash,
        proof_handles: @proof_handles.map(&:to_h)
      }
    end

    private

    def post_hash(uri, hash)
      uri = URI(uri + '/hashes')
      request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      request.body = { hashes: [hash] }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    end
  end
end
