# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/diffable_forward'
require 'netomox/topology/tp_attr/mddo_ospf_timer'
require 'netomox/topology/tp_attr/mddo_ospf_neighbor'

module Netomox
  module Topology
    # attribute for L1 termination point
    class MddoL1TPAttribute < AttributeBase
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :description, :flags

      # Attribute definition of L1 termination-point
      ATTR_DEFS = [
        { int: :description, ext: 'description', default: '' },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@path}"
      end
    end

    # attribute for L2 termination point
    class MddoL2TPAttribute < AttributeBase
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] encapsulation
      #   @return [String]
      # @!attribute [rw] switchport_mode
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :description, :encapsulation, :switchport_mode, :flags

      # Attribute definition of L2 termination-point
      ATTR_DEFS = [
        { int: :description, ext: 'description', default: '' },
        { int: :encapsulation, ext: 'encapsulation', default: '' },
        { int: :switchport_mode, ext: 'switchport-mode', default: '' },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@path}"
      end
    end

    # attribute for L3 termination point
    class MddoL3TPAttribute < AttributeBase
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :description, :ip_addrs, :flags

      # Attribute definition of L2 termination-point
      ATTR_DEFS = [
        { int: :description, ext: 'description', default: '' },
        { int: :ip_addrs, ext: 'ip-address', default: [] },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@path}"
      end
    end

    # attribute for ospf-area termination point
    class MddoOspfAreaTPAttribute < AttributeBase
      # @!attribute [rw] network_type
      #   @return [String]
      #   @todo enum %w(p2p, broadcast, non_broadcast)
      # @!attribute [rw] priority
      #   @return [Integer]
      # @!attribute [rw] metric
      #   @return [Integer]
      # @!attribute [rw] passive
      #   @return [Boolean]
      # @!attribute [rw] timer
      #   @return [MddoOspfTimer]
      # @!attribute [rw] neighbors
      #   @return [Array<MddoOspfNeighbor>]
      # @!attribute [rw] area
      #   @return [Integer]
      attr_accessor :network_type, :priority, :metric, :passive, :timer, :neighbors, :area

      # Attribute definition of L3 node
      ATTR_DEFS = [
        { int: :network_type, ext: 'network-type', default: '' },
        { int: :priority, ext: 'priority', default: 10 },
        { int: :metric, ext: 'metric', default: 1 },
        { int: :passive, ext: 'passive', default: false },
        { int: :timer, ext: 'timer', default: {} },
        { int: :neighbors, ext: 'neighbor', default: [] },
        { int: :area, ext: 'area', default: -1 }
      ].freeze

      include Diffable

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type) # merge ATTR_DEFS
        @timer = convert_timer(data)
        @neighbors = convert_neighbors(data)
      end

      # @return [String]
      def to_s
        "attribute: #{@name}"
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [MddoOspfTimer] Converted attribute data
      def convert_timer(data)
        key = @attr_table.ext_of(:timer)
        MddoOspfTimer.new(operative_hash_key?(data, key) ? data[key] : {}, key)
      end

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoOspfNeighbor>] Converted attribute data
      def convert_neighbors(data)
        key = @attr_table.ext_of(:neighbors)
        operative_array_key?(data, key) ? data[key].map { |n| MddoOspfNeighbor.new(n, key) } : []
      end
    end
  end
end
