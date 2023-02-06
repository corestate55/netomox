# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/diffable_forward'
require 'netomox/topology/tp_attr/rfc_vlan_id_name'

module Netomox
  module Topology
    # attribute for L2 termination point
    class L2TPAttribute < AttributeBase
      # @!attribute [rw] descr
      #   @return [String]
      # @!attribute [rw] max_frame_size
      #   @return [Integer]
      # @!attribute [rw] mac_addr
      #   @return [String]
      # @!attribute [rw] eth_encap
      #   @return [String]
      # @!attribute [rw] port_vlan_id
      #   @return [Integer]
      # @!attribute [rw] vlan_id_names
      #   @return [Array<String>]
      # @!attribute [rw] tp_state
      #   @return [String]
      attr_accessor :descr, :max_frame_size, :mac_addr, :eth_encap,
                    :port_vlan_id, :vlan_id_names, :tp_state

      # Attribute definition of L2 termination-point
      ATTR_DEFS = [
        { int: :descr, ext: 'description', default: '' },
        { int: :max_frame_size, ext: 'maximum-frame-size', default: 1500 },
        { int: :mac_addr, ext: 'mac-address', default: '' },
        { int: :eth_encap, ext: 'eth-encapsulation', default: '' },
        { int: :port_vlan_id, ext: 'port-vlan-id', default: 0 },
        { int: :vlan_id_names, ext: 'vlan-id-name', default: [] },
        { int: :tp_state, ext: 'tp-state', default: 'in-use' }
      ].freeze

      include Diffable

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @vlan_id_names = convert_vlan_id_names(data)
      end

      # @return [String]
      def to_s
        "attribute: #{@descr}" # TODO
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<L2VlanIdName>] Converted attribute data
      def convert_vlan_id_names(data)
        key = @attr_table.ext_of(:vlan_id_names)
        operative_array_key?(data, key) ? data[key].map { |p| L2VlanIdName.new(p, key) } : []
      end
    end

    # attribute for L3 termination point
    class L3TPAttribute < AttributeBase
      # @!attribute [rw] ip_addrs
      #   @return [Array<String>]
      attr_accessor :ip_addrs

      # Attribute definition of L3 termination-point
      ATTR_DEFS = [{ int: :ip_addrs, ext: 'ip-address', default: [] }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@ip_addrs}"
      end
    end
  end
end
