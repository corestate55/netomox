# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/diff_forward'

module Netomox
  module Topology
    # Port VLAN ID & Name, for L2 attribute
    class L2VlanIdName < AttributeBase
      ATTR_DEFS = [
        { int: :id, ext: 'vlan-id', default: 0 },
        { int: :name, ext: 'vlan-name', default: '' }
      ].freeze
      attr_accessor :id, :name

      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      def to_s
        "VLAN: #{@id},#{@name}"
      end
    end

    # attribute for L2 termination point
    class L2TPAttribute < AttributeBase
      ATTR_DEFS = [
        { int: :descr, ext: 'description', default: '' },
        { int: :max_frame_size, ext: 'maximum-frame-size', default: 1500 },
        { int: :mac_addr, ext: 'mac-address', default: '' },
        { int: :eth_encap, ext: 'eth-encapsulation', default: '' },
        { int: :port_vlan_id, ext: 'port-vlan-id', default: 0 },
        { int: :vlan_id_names, ext: 'vlan-id-name', default: [] },
        { int: :tp_state, ext: 'tp-state', default: 'in-use' }
      ].freeze
      attr_accessor :descr, :max_frame_size, :mac_addr, :eth_encap,
                    :port_vlan_id, :vlan_id_names, :tp_state

      include Diffable
      include SubAttributeOps

      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @vlan_id_names = setup_vlan_id_names(data)
      end

      def to_s
        "attribute: #{@descr}" # TODO
      end

      def diff(other)
        diff_of(:vlan_id_names, other)
      end

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
      ATTR_DEFS = [
        { int: :ip_addrs, ext: 'ip-address', default: [] }
      ].freeze
      attr_accessor :ip_addrs

      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      def to_s
        "attribute: #{@ip_addrs}"
      end
    end
  end
end
