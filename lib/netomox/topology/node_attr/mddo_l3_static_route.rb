# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # L3 prefix for L3 attribute
    class MddoL3StaticRoute < SubAttributeBase
      # @!attribute [rw] prefix
      #   @return [String] IP address/prefix-length
      # @!attribute [rw] next_hop
      #   @return [String] IP address
      # @!attribute [rw] interface
      #   @return [String] interface (device) name
      # @!attribute [rw] metric
      #   @return [Integer]
      # @!attribute [rw] preference
      #   @return [Integer]
      # @!attribute [rw] description
      #   @return [String]
      attr_accessor :prefix, :next_hop, :interface, :metric, :preference, :description

      # Attribute definition of MDDO static route (for L3 node)
      ATTR_DEFS = [
        { int: :prefix, ext: 'prefix', default: '' },
        { int: :next_hop, ext: 'next-hop', default: '' },
        { int: :interface, ext: 'interface', default: '' },
        { int: :metric, ext: 'metric', default: 10 },
        { int: :preference, ext: 'preference', default: 1 },
        { int: :description, ext: 'description', default: '' }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end
  end
end
