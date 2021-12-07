# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/node_attr_rfc_prefix'

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
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :node_type, :prefixes, :flags
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] node_type "segment" or "node"
      # @param [Array<Hash>] prefixes Prefixes at the node
      # @param [Array<String>] flags Flags
      def initialize(node_type: '', prefixes: [], flags: [])
        @node_type = node_type
        @prefixes = prefixes.empty? ? [] : prefixes.map { |p| L3Prefix.new(**p) }
        @flags = flags
        @type = "#{NS_MDDO}:l3-node-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'node-type' => @node_type,
          'prefix' => @prefixes.map(&:topo_data),
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @node_type.empty? && @prefixes.empty? && @flags.empty?
      end
    end
  end
end
