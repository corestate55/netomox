# frozen_string_literal: true

require 'netomox/topology/network_attr/base'

module Netomox
  module Topology
    # attribute for L1 network
    class MddoL1NetworkAttribute < NetworkAttributeBase; end
    # attribute for L2 network
    class MddoL2NetworkAttribute < NetworkAttributeBase; end
    # attribute for L3 network
    class MddoL3NetworkAttribute < NetworkAttributeBase; end
  end
end
