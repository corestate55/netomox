# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/node_attr/rfc_prefix'
require 'netomox/dsl/node_attr/mddo_static_route'
require 'netomox/dsl/node_attr/mddo_ospf_redistribute'

module Netomox
  module DSL
    # attribute for mddo-topology layer1 node
    class MddoL1NodeAttribute
      # @!attribute [rw] os_type
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :os_type, :flags
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] os_type OS type string of the device
      def initialize(os_type: '', flags: [])
        @os_type = os_type
        @flags = flags
        @type = "#{NS_MDDO}:l1-node-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'os-type' => @os_type,
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @os_type.empty? && @flags.empty?
      end
    end

    # attribute for mddo-topology layer2 node
    class MddoL2NodeAttribute
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] vlan_id
      #   @return [Integer]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :name, :vlan_id, :flags
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] name Layer1 device name under the L2 node (bridge)
      # @param [Integer] vlan_id VLAN id of the bridge
      # @param [Array<String>] flags Flags
      def initialize(name: '', vlan_id: 0, flags: [])
        @name = name
        @vlan_id = vlan_id
        @flags = flags
        @type = "#{NS_MDDO}:l2-node-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'vlan-id' => @vlan_id,
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @name.empty? && vlan_id.zero?
      end
    end

    # attribute for mddo-topology layer3 node
    class MddoL3NodeAttribute
      # @!attribute [rw] node_type
      #   @return [String]
      # @!attribute [rw] prefixes
      #   @return [Array<L3Prefix>]
      # @!attribute [rw] static_routes
      #   @return [Array<MddoStaticRoute>]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :node_type, :prefixes, :static_routes, :flags
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] node_type "segment" or "node"
      # @param [Array<Hash>] prefixes Prefixes at the node
      # @param [Array<Hash>] static_routes Static routes at the node
      # @param [Array<String>] flags Flags
      def initialize(node_type: '', prefixes: [], static_routes: [], flags: [])
        @node_type = node_type
        @prefixes = prefixes.map { |p| L3Prefix.new(**p) }
        @static_routes = static_routes.map { |s| MddoStaticRoute.new(**s) }
        @flags = flags
        @type = "#{NS_MDDO}:l3-node-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'node-type' => @node_type,
          'prefix' => @prefixes.map(&:topo_data),
          'static-route' => @static_routes.map(&:topo_data),
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @node_type.empty? && @prefixes.empty? && @static_routes.empty? && @flags.empty?
      end
    end

    # attribute for mddo-topology ospf-area node (ospf proc)
    class MddoOspfAreaNodeAttribute
      # @!attribute [rw] node_type
      #   @return [String]
      # @!attribute [rw] router_id
      #   @return [String] dotted-quote
      # @!attribute [rw] log_adjacency_change
      #   @return [Boolean]
      # @!attribute [rw] redistribute_list
      #   @return [Array<MddoOspfRedistribute>]
      attr_accessor :node_type, :router_id, :log_adjacency_change, :redistribute_list
      # @!attribute [r] type
      #   @return [String]
      # @!attribute [r] router_id_source
      #   @return [Symbol] TODO: enum {:static, :auto}
      attr_reader :type, :router_id_source

      # @param [String] node_type
      # @param [String] router_id
      # @param [Boolean] log_adjacency_change
      # @param [Array<Hash>] redistribute
      def initialize(node_type: '', router_id: '', log_adjacency_change: false, redistribute: [])
        @node_type = node_type
        @router_id_source = router_id.empty? ? :auto : :static
        @router_id = router_id # TODO: router id selection
        @log_adjacency_change = log_adjacency_change
        @redistribute_list = redistribute.map { |r| MddoOspfRedistribute.new(**r) }
        @type = "#{NS_MDDO}:ospf-area-node-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'node-type' => @node_type,
          'router-id' => @router_id,
          'router-id-source' => @router_id_source.to_s,
          'log-adjacency-change' => @log_adjacency_change,
          'redistribute' => @redistribute_list.map(&:topo_data)
        }
      end

      # @return [Boolean]
      def empty?
        @node_type.empty? && @router_id.empty? && @redistribute_list.empty?
      end
    end
  end
end
