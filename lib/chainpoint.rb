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

require 'json'
require 'net/https'

require 'chainpoint/version'
require 'chainpoint/hash'
require 'chainpoint/proof'
require 'chainpoint/proof_handle'

module Chainpoint
  NODE_LIST_ENDPOINTS = ['https://a.chainpoint.org/nodes/random',
                         'https://b.chainpoint.org/nodes/random',
                         'https://c.chainpoint.org/nodes/random'].freeze

  def self.select_nodes(number)
    node_list_uri = URI(NODE_LIST_ENDPOINTS.sample)
    servers = JSON.parse(Net::HTTP.get(node_list_uri)).sample(number)
    servers.map { |server| server['public_uri'] }
  end
end
