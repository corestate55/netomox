# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/attr_base'

module Netomox
  module DSL
    # VLAN info for L2 termination point attribute
    class L2VlanIdName
      attr_accessor :id, :name

      def initialize(id: 0, name: '')
        @id = id
        @name = name
      end

      def topo_data
        {
          'vlan-id' => @id,
          'vlan-name' => @name
        }
      end
    end

    # attribute for L2 termination point
    class L2TPAttribute
      attr_accessor :descr, :max_frame_size, :mac_addr, :eth_encap,
                    :port_vlan_id, :vlan_id_names, :tp_state
      attr_reader :type

      # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
      def initialize(descr: '', max_frame_size: 1500, mac_addr: '',
                     eth_encap: '', port_vlan_id: 0,
                     vlan_id_names: [], tp_state: 'in-use')
        @descr = descr
        @max_frame_size = max_frame_size
        @mac_addr = mac_addr
        @eth_encap = eth_encap
        @port_vlan_id = port_vlan_id
        @vlan_id_names = if vlan_id_names.empty?
                           []
                         else
                           vlan_id_names.map { |v| L2VlanIdName.new(**v) }
                         end
        @tp_state = tp_state
        @type = "#{NS_L2NW}:l2-termination-point-attributes"
      end
      # rubocop:enable Metrics/ParameterLists, Metrics/MethodLength

      def empty?
        @descr.empty? && @mac_addr.empty? && port_vlan_id.zero? \
      && @eth_encap.empty? && @vlan_id_names.empty?
      end

      def topo_data
        {
          'description' => @descr,
          'maximum-frame-size' => @max_frame_size,
          'mac-address' => @mac_addr,
          'eth-encapsulation' => @eth_encap,
          'port-vlan-id' => @port_vlan_id,
          'vlan-id-name' => @vlan_id_names.map(&:topo_data),
          'tp-state' => @tp_state
        }
      end
    end

    # attribute for L3 termination point
    class L3TPAttribute
      attr_accessor :ip_addrs
      attr_reader :type

      def initialize(ip_addrs: [])
        @ip_addrs = ip_addrs
        @type = "#{NS_L3NW}:l3-termination-point-attributes"
      end

      def empty?
        @ip_addrs.empty?
      end

      def topo_data
        { 'ip-address' => @ip_addrs }
      end
    end

    # attribute for ops-topology termination point
    class OpsTPAttribute < OpsAttributeBase
      def initialize(hash)
        super(hash)
        @type = "#{NS_OPS}:ops-termination-point-attributes"
      end
    end
  end
end
