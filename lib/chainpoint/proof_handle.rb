# frozen_string_literal: true

module Chainpoint
  class ProofHandle
    attr_reader :uri, :node_hash_id

    def initialize(uri, node_hash_id)
      @uri = uri
      @node_hash_id = node_hash_id
    end

    def proof
      data = request_proof
      return unless data['proof']

      Chainpoint::Proof.new(data['proof'], data['hash_id_node'], data['anchors_complete'])
    end

    def to_h
      { uri: @uri, node_hash_id: @node_hash_id }
    end

    private

    def request_proof
      response = Net::HTTP.get_response(URI(@uri + '/proofs/' + @node_hash_id))
      body = JSON.parse(response.body)
      raise ArgumentError, body['message'] unless response.is_a? Net::HTTPSuccess

      body.first
    end
  end
end
