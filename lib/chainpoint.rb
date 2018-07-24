require "chainpoint/version"
require "net/https"
require "json"
require "digest"

module Chainpoint
  def self.pickup_server()
    uri = URI(pickup_node_list_server)
    r = Net::HTTP.get(uri)
    j = JSON.parse(r)
    return j[rand(j.length)]["public_uri"]
  end

  def self.submit_data(data)
    hash = Digest::SHA256.digest(data).unpack('H*')[0]
    return submit(hash)
  end

  def self.submit(hash)
    uri = URI(pickup_server + "/hashes")
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = {hashes: [hash]}.to_json
    res = Net::HTTP.start(
      uri.hostname, uri.port, use_ssl: uri.scheme == "https"
    ) do |http|
      http.request(req)
    end
    return JSON.parse(res.body)
  end

  def self.get_proof(hash_id_node)
    uri = URI(pickup_server + '/proofs/' + hash_id_node)
    r = Net::HTTP.get(uri)
    return JSON.parse(r)
  end

  def self.verify(proof)
    uri = URI(pickup_server + "/verify")
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = {proofs: [proof]}.to_json
    res = Net::HTTP.start(
      uri.hostname, uri.port, use_ssl: uri.scheme == "https"
    ) do |http|
      http.request(req)
    end
    return JSON.parse(res.body)
  end

  private
    def self.pickup_node_list_server
      endpoint_array = [
        'https://a.chainpoint.org/nodes/random',
        'https://b.chainpoint.org/nodes/random',
        'https://c.chainpoint.org/nodes/random'
      ]
      return endpoint_array[rand(endpoint_array.length)]
    end
end
