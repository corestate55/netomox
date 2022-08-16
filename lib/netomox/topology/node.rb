# frozen_string_literal: true

require 'netomox/const'
require 'netomox/topology/tp'
require 'netomox/topology/support_base'
require 'netomox/topology/node_attr/rfc'
require 'netomox/topology/node_attr/mddo'
require 'netomox/topology/base'

module Netomox
  module Topology
    # Node for topology data
    class Node < TopoObjectBase
      # @!attribute [rw] termination_points
      #   @return [Array<TermPoint>]
      attr_accessor :termination_points

      # Attribute type key and its class for Node
      ATTR_KEY_KLASS_LIST = [
        { key: "#{NS_L2NW}:l2-node-attributes", klass: L2NodeAttribute },
        { key: "#{NS_L3NW}:l3-node-attributes", klass: L3NodeAttribute },
        { key: "#{NS_MDDO}:l1-node-attributes", klass: MddoL1NodeAttribute },
        { key: "#{NS_MDDO}:l2-node-attributes", klass: MddoL2NodeAttribute },
        { key: "#{NS_MDDO}:l3-node-attributes", klass: MddoL3NodeAttribute },
        { key: "#{NS_MDDO}:ospf-area-node-attributes", klass: MddoOspfAreaNodeAttribute }
      ].freeze

      # @param [Hash] data RFC8345 data (node element)
      # @param [String] parent_path Parent (network) path
      def initialize(data, parent_path)
        super(data['node-id'], parent_path)

        setup_termination_points(data)
        setup_supports(data, 'supporting-node', SupportingNode)
        setup_attribute(data, ATTR_KEY_KLASS_LIST)
        setup_diff_state(data)
      end

      # @param [Node] other Node to compare
      # @return [Node] Result of comparison
      def diff(other)
        # forward check
        d_node = Node.new({ 'node-id' => @name }, @parent_path)
        attr = :termination_points
        d_node.termination_points = diff_forward_check_of(attr, other)
        d_node.supports = diff_supports(other)
        d_node.attribute = diff_attribute(other)
        d_node.diff_state = select_diff_state(other)
        # backward check
        d_node.diff_backward_check(%i[termination_points supports attribute])
        # return
        d_node
      end

      def fill_diff_state
        fill_diff_state_of(%i[termination_points supports attribute])
      end

      # @return [String]
      def to_s
        "node:#{@name}"
      end

      # Convert ot data for RFC8345 format
      # @return [Hash]
      def to_data
        data = {
          'node-id' => @name,
          '_diff_state_' => @diff_state.to_data,
          "#{NS_TOPO}:termination-point" => @termination_points.map(&:to_data)
        }
        add_supports_and_attr(data, 'supporting-node')
      end

      # Find all support-node that links to specified network
      # @param [String] nw_ref Network name
      # @return [Array<SupportingNode>] (empty array if not found)
      def find_all_supports_by_network(nw_ref)
        @supports.find_all do |support|
          support.ref_network == nw_ref
        end
      end

      # @param [String] tp_ref Term-point name
      # @return [TermPoint, nil] Found term-point (nil if not found)
      def find_tp_by_name(tp_ref)
        @termination_points.find { |tp| tp.name == tp_ref }
      end

      # @@param [Symbol] key Method name Dread attribute)
      # @return [Array<TermPoint>] Found term-points (empty array if not found)
      def find_all_tps_with_attribute(key)
        @termination_points.filter { |tp| tp.attribute.attribute?(key) }
      end

      private

      def setup_termination_points(data)
        @termination_points = []
        tp_key = "#{NS_TOPO}:termination-point"
        return unless data.key?("#{NS_TOPO}:termination-point")

        @termination_points = data[tp_key].map do |tp|
          create_termination_point(tp)
        end
      end

      def create_termination_point(data)
        TermPoint.new(data, @path)
      end
    end
  end
end
