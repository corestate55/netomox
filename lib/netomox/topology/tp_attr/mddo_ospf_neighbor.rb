# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # ospf neighbor for MDDO ospf-area term-point attribute
    class MddoOspfNeighbor < AttributeBase
      # @!attribute [rw] router_id
      #   @return [String]
      # @!attribute [rw] ip_addr
      #   @return [String]
      attr_accessor :router_id, :ip_addr

      # Attribute definition of ospf neighbor
      ATTR_DEFS = [
        { int: :router_id, ext: 'router-id', default: '' },
        { int: :ip_addr, ext: 'ip-address', default: '' }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "Neighbor: router_id:#{router_id}, ip_addr:#{ip_addr}"
      end
    end
  end
end
