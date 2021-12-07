# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/node_attr_rfc_prefix'

module Netomox
  module DSL
    # attribute for mddo-topology layer1 node
    class MddoL1NodeAttribute
      # @!attribute [rw] os_type
      #   @return [String]
      attr_accessor :os_type
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] os_type OS type string of the device
      def initialize(os_type: '')
        @os_type = os_type
        @type = "#{NS_MDDO}:l1-node-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'os_type' => os_type
        }
      end

      # @return [Boolean]
      def empty?
        @os_type.empty?
      end
    end

    # attribute for mddo-topology layer2 node
    class MddoL2NodeAttribute
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] vlan_id
      #   @return [Integer]
      attr_accessor :name, :vlan_id
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] name Layer1 device name under the L2 node (bridge)
      # @param [Integer] vlan_id VLAN id of the bridge
      def initialize(name: '', vlan_id: 0)
        @name = name
        @vlan_id = vlan_id
        @type = "#{NS_MDDO}:l2-node-attribute"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'vlan_id' => @vlan_id
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
      attr_accessor :node_type, :prefixes
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] node_type "segment" or "node"
      # @param [Array<L3Prefix>] prefixes Prefixes at the node
      def initialize(node_type: '', prefixes: [])
        @node_type = node_type
        @prefixes = prefixes
        @type = "#{NS_MDDO}:l3-node-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'node_type' => @node_type,
          'prefix' => @prefixes.map(&:topo_data)
        }
      end

      # @return [Boolean]
      def empty?
        @node_type.empty? && @prefixes.empty?
      end
    end
  end
end
