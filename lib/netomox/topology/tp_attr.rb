# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/diff_forward'

module Netomox
  module Topology
    # Port VLAN ID & Name, for L2 attribute
    class L2VlanIdName < AttributeBase
      # @!attribute [rw] id
      #   @return [Integer]
      # @!attribute [rw] name
      #   @return [String]
      attr_accessor :id, :name

      # Attribute definition of Port VLAN ID & Name for L2 network
      ATTR_DEFS = [
        { int: :id, ext: 'vlan-id', default: 0 },
        { int: :name, ext: 'vlan-name', default: '' }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "VLAN: #{@id},#{@name}"
      end
    end

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
      include SubAttributeOps

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @vlan_id_names = setup_vlan_id_names(data)
      end

      # @return [String]
      def to_s
        "attribute: #{@descr}" # TODO
      end

      # @param [L2TPAttribute] other Target to compare
      # @return [L2TPAttribute]
      def diff(other)
        diff_of(:vlan_id_names, other)
      end

      # Fill diff state
      # @param [Hash] state_hash
      # @return [L2TPAttribute]
      def fill(state_hash)
        fill_of(:vlan_id_names, state_hash)
      end

      private

      def setup_vlan_id_names(data)
        key = 'vlan-id-name' # alias
        if data.key?(key) && !data[key].empty?
          data[key].map { |p| L2VlanIdName.new(p, key) }
        else
          []
        end
      end
    end

    # attribute for L3 termination point
    class L3TPAttribute < AttributeBase
      # @!attribute [rw] ip_addrs
      #   @return [Array<String>]
      attr_accessor :ip_addrs

      # Attribute definition of L3 termination-point
      ATTR_DEFS = [
        { int: :ip_addrs, ext: 'ip-address', default: [] }
      ].freeze

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
