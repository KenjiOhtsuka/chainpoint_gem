# frozen_string_literal: true

require 'base64'
require 'msgpack'
require 'zlib'

module Chainpoint
  class Proof
    attr_reader :proof, :hash_id_node, :anchors_complete

    def initialize(proof, hash_id_node = nil, anchors_complete = [])
      @proof = proof
      @hash_id_node = hash_id_node
      @anchors_complete = anchors_complete
    end

    def decode
      MessagePack.unpack(
        Zlib::Inflate.inflate(
          Base64.decode64(@proof)
        )
      )
    end

    def verify
      uri = URI(Chainpoint.select_nodes(1).first + '/verify')
      request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      request.body = { proofs: [@proof] }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      JSON.parse(response.body).first
    end
  end
end
