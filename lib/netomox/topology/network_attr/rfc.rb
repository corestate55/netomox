# frozen_string_literal: true

require 'netomox/topology/network_attr/base'

module Netomox
  module Topology
    # attribute for L2 network
    class L2NetworkAttribute < NetworkAttributeBase
      def initialize(data, type)
        super([], data, type)
      end
    end

    # attribute for L3 network
    class L3NetworkAttribute < NetworkAttributeBase
      def initialize(data, type)
        super([], data, type)
      end
    end
  end
end
