# frozen_string_literal: true

# chainpoint_gem
# Copyright (C) 2019 Kenji Otsuka
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'chainpoint/version'
require 'net/https'
require 'json'
require 'digest'

# Base class for interacting with a chainpoint node
class Chainpoint
  NODE_LIST_ENDPOINTS = ['https://a.chainpoint.org/nodes/random',
                         'https://b.chainpoint.org/nodes/random',
                         'https://c.chainpoint.org/nodes/random'].freeze

  NUM_SERVERS = 3

  def initialize(server_url = nil, num_servers: NUM_SERVERS)
    @server_urls = [server_url] || pickup_servers(num_servers)
  end

  # Submit data into the chainpoint server.
  #
  # @param data [Object] data which you want to submit into the chainpoint server.
  def self.submit_data(data)
    new.submit_data(data)
  end

  # Submit data into the chainpoint server.
  #
  # @param data [Object] data which you want to submit into the chainpoint server.
  def submit_data(data)
    hash = Digest::SHA256.digest(data).unpack1('H*')
    submit(hash)
  end

  # Submit hash string into the chainpoint server.
  #
  # @param data [String] hash String which you want to submit into the chainpoint server.
  def self.submit(hash)
    new.submit(hash)
  end

  # Submit a hash to a chainpoint server
  #
  # @param data [String] hash String which you want to submit into the chainpoint server.
  # @return [Array] An array of Chainpoint::Hash objects
  def submit(hash)
    @server_urls.map do |url|
      response = post_hash(url, hash)
      JSON.parse(response.body)['hashes'].map { |h| h.merge('uri' => url) }
    end.flatten
  end

  # Get proof data from the chainpoint server.
  #
  # @param URI [String] hash id node of the proof
  # @param node_hash_id [String] hash id node of the proof
  # @return [JSON]
  def self.get_proof(uri, node_hash_id)
    new(uri).get_proof(node_hash_id)
  end

  # Get proof data from the chainpoint server.
  #
  # @param hash_id_node [String] hash id node of the proof
  # @return [JSON]
  def get_proof(node_hash_id)
    uri = URI(@server_urls.first + '/proofs/' + node_hash_id)
    JSON.parse(Net::HTTP.get(uri))
  end

  # Verify the proof data.
  #
  # @param proof [String] proof string
  def self.verify(proof)
    new(num_servers: 1).verify(proof)
  end

  # Verify the proof data.
  #
  # @param proof [String] proof string
  def verify(proof)
    uri = URI(@server_urls.first + '/verify')
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.body = { proofs: [proof] }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end

  private

  def pickup_servers(num_servers)
    node_list_uri = URI(NODE_LIST_ENDPOINTS.sample)
    servers = JSON.parse(Net::HTTP.get(node_list_uri)).sample(num_servers)
    servers.map { |server| server['public_uri'] }
  end

  def post_hash(url, hash)
    uri = URI(url + '/hashes')
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.body = { hashes: [hash] }.to_json

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
  end
end
