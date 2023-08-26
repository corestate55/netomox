# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/diffable_forward'
require 'netomox/topology/tp_attr/mddo_ospf_timer'
require 'netomox/topology/tp_attr/mddo_ospf_neighbor'
require 'netomox/topology/tp_attr/mddo_bgp_timer'

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

      # Attribute definition of ospf-area node
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
        "attribute: #{@path}"
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

    # attribute for bgp-proc termination point
    class MddoBgpProcTPAttribute < AttributeBase
      # @!attribute [rw] local_as
      #   @return [Integer]
      # @!attribute [rw] local_ip
      #   @return [String]
      # @!attribute [rw] remote_as
      #   @return [Integer]
      # @!attribute [rw] remote_ip
      #   @return [String]
      # @!attribute [rw] confederation
      #   @return [Integer] ASN
      # @!attribute [rw] route_reflector_client
      #   @return [Boolean]
      # @!attribute [rw] cluster_id
      #   @return [String] IP
      # @!attribute [rw] peer_group
      #   @return [String]
      # @!attribute [rw] import_policies
      #   @return [Array<String>]
      # @!attribute [rw] export_policies
      #   @return [Array<String>]
      # @!attribute [rw] timer
      #   @return [] # TODO
      attr_accessor :local_as, :local_ip, :remote_as, :remote_ip, :confederation, :route_reflector_client, :cluster_id,
                    :peer_group, :import_policies, :export_policies, :timer

      # Attribute definition of bgp node
      ATTR_DEFS = [
        { int: :local_as, ext: 'local-as', default: -1 },
        { int: :local_ip, ext: 'local-ip', default: '' },
        { int: :remote_as, ext: 'remote-as', default: -1 },
        { int: :remote_ip, ext: 'remote-ip', default: '' },
        { int: :confederation, ext: 'confederation', default: -1 },
        { int: :route_reflector_client, ext: 'route-reflector-client', default: false },
        { int: :cluster_id, ext: 'cluster-id', default: '' },
        { int: :peer_group, ext: 'peer-group', default: '' },
        { int: :import_policies, ext: 'import-policy', default: [] },
        { int: :export_policies, ext: 'export-policy', default: [] },
        { int: :timer, ext: 'timer', default: {} }
      ].freeze

      include Diffable

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type) # merge ATTR_DEFS
        @timer = convert_timer(data)
      end

      # @return [String]
      def to_s
        "attribute: #{@path}"
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [MddoBgpTimer] Converted attribute data
      def convert_timer(data)
        key = @attr_table.ext_of(:timer)
        MddoBgpTimer.new(operative_hash_key?(data, key) ? data[key] : {}, key)
      end
    end

    # attribute for bgp-as termination point
    class MddoBgpAsTPAttribute < MddoL1TPAttribute; end
  end
end
