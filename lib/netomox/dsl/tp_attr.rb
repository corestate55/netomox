# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/attr_base'

module Netomox
  module DSL
    # VLAN info for L2 termination point attribute
    class L2VlanIdName
      # @!attribute [rw] id
      #   @return [Integer]
      # @!attribute [rw] name
      #   @return [String]
      attr_accessor :id, :name

      # @param [Integer] id VLAN ID
      # @param [String] name VLAN name
      def initialize(id: 0, name: '')
        @id = id
        @name = name
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'vlan-id' => @id,
          'vlan-name' => @name
        }
      end
    end

    # attribute for L2 termination point
    class L2TPAttribute
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
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] descr
      # @param [Integer] max_frame_size
      # @param [String] mac_addr
      # @param [String] eth_encap
      # @param [Integer] port_vlan_id
      # @param [Array<String>] vlan_id_names
      # @param [String] tp_state
      # rubocop:disable Metrics/ParameterLists
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
      # rubocop:enable Metrics/ParameterLists

      # @return [Boolean]
      def empty?
        @descr.empty? && @mac_addr.empty? && port_vlan_id.zero? \
      && @eth_encap.empty? && @vlan_id_names.empty?
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
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
      # @!attribute [rw] ip_addrs
      #   @return [Array<String>]
      attr_accessor :ip_addrs
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [Array<String>] ip_addrs
      def initialize(ip_addrs: [])
        @ip_addrs = ip_addrs
        @type = "#{NS_L3NW}:l3-termination-point-attributes"
      end

      # @return [Boolean]
      def empty?
        @ip_addrs.empty?
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        { 'ip-address' => @ip_addrs }
      end
    end

    # attribute for ops-topology termination point
    class OpsTPAttribute < OpsAttributeBase
      # @param [Hash] hash Key-Value data of any attribute
      def initialize(hash)
        super(hash)
        @type = "#{NS_OPS}:ops-termination-point-attributes"
      end
    end
  end
end
