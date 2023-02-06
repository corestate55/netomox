# frozen_string_literal: true

require_relative 'p_object_base'
require_relative 'p_node'
require_relative 'p_link'

module Netomox
  module PseudoDSL
    # pseudo network
    class PNetwork < PObjectBase
      # @!attribute [rw] nodes
      #   @return [Array<PNode>]
      # @!attribute [rw] links
      #   @return [Array<PLink>]
      # @!attribute [rw] type
      #   @return [String]
      attr_accessor :nodes, :links, :type

      # @param [String] name Name of the network
      def initialize(name)
        super(name)
        @type = nil # Hash
        @nodes = [] # Array<PNode>
        @links = [] # Array<PLink>
      end

      # print data to stderr (for debugging)
      # @return [void]
      def dump
        warn "network: #{name}"
        warn '  nodes:'
        @nodes.each { |n| warn "    - #{n}" }
        warn '  links:'
        @links.each { |l| warn "    - #{l}" }
      end

      # Find or create new node
      # @param [String] node_name Name of the node
      # @return [PNode] Found or added node
      def node(node_name)
        found_node = find_node_by_name(node_name)
        return found_node if found_node

        new_node = PNode.new(node_name)
        @nodes.push(new_node)
        new_node
      end

      # Find or create link (unidirectional)
      # @param [String] src_node_name Source node name
      # @param [String] src_tp_name Source term-point name (on source node)
      # @param [String] dst_node_name Destination node name
      # @param [String] dst_tp_name Destination term-point name (on destination node)
      # @return [PLink] Found or added link
      def link(src_node_name, src_tp_name, dst_node_name, dst_tp_name)
        found_link = find_link_by_src_dst_name(src_node_name, src_tp_name, dst_node_name, dst_tp_name)
        return found_link if found_link

        src = PLinkEdge.new(src_node_name, src_tp_name)
        dst = PLinkEdge.new(dst_node_name, dst_tp_name)
        new_link = PLink.new(src, dst)
        @links.push(new_link)
        new_link
      end

      # @param [String] node_name Node name to find
      # @return [nil, PNode] Node if found or nil if not found
      def find_node_by_name(node_name)
        @nodes.find { |node| node.name == node_name }
      end

      # @param [PLinkEdge] edge Source link-edge
      # @return [nil, PLink] Link if found or  nil if not found
      def find_link_by_src_edge(edge)
        find_link_by_src_name(edge.node, edge.tp)
      end

      # @param [String] node_name Source node name
      # @param [String] tp_name destination node name (on source node)
      # @return [nil, PLink] Link if found or nil if not found
      def find_link_by_src_name(node_name, tp_name)
        @links.find do |link|
          link.src.node == node_name && link.src.tp == tp_name
        end
      end

      # @param [String] node_name Source node name
      # @return [Array<PLink>] Links connected with the node
      def find_all_links_by_src_name(node_name)
        @links.find_all { |link| link.src.node == node_name }
      end

      # @param [String] node_name Source node name
      # @return [Array<PLinkEdge>] Facing (destination) edges connected with the node
      def find_all_edges_by_src_name(node_name)
        find_all_links_by_src_name(node_name).map(&:dst)
      end

      # @param [PLinkEdge] edge Link-edge to find
      # @return [Array<PNode, PTermPoint>] Node and term-point if found or nil if not found
      def find_node_tp_by_edge(edge)
        node = find_node_by_name(edge.node)
        return [] unless node

        tp = node.find_tp_by_name(edge.tp)
        [node, tp]
      end

      # @param [String] node_name Node name
      # @param [String] tp_name Term-point name
      # @return [Array<PNode, PTermPoint>] Node and term-point if found or nil if not found
      def find_node_tp_by_name(node_name, tp_name)
        find_node_tp_by_edge(PLinkEdge.new(node_name, tp_name))
      end

      # @param [String] node1 Source node name
      # @param [String] tp1 Source term-point name (on source node)
      # @param [String] node2 Destination node name
      # @param [String] tp2 Destination term-point name (on destination node)
      # @return [nil, PLink] Link if found or nil if not found
      def find_link_by_src_dst_name(node1, tp1, node2, tp2)
        @links.find do |link|
          link.src.node == node1 && link.src.tp == tp1 &&
            link.dst.node == node2 && link.dst.tp == tp2
        end
      end
    end
  end
end
