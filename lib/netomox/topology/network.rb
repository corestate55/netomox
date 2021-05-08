# frozen_string_literal: true

require 'netomox/const'
require 'netomox/topology/node'
require 'netomox/topology/link'
require 'netomox/topology/support_base'
require 'netomox/topology/network_attr'
require 'netomox/topology/base'

module Netomox
  module Topology
    # Network for topology data
    class Network < TopoObjectBase
      # @!attribute [rw] network_types
      # @!attribute [rw] nodes
      #   @return [Array<Node>]
      # @!attribute [rw] links
      #   @return [Array<Link>]
      attr_accessor :network_types, :nodes, :links

      ATTR_KEY_KLASS_LIST = [
        { key: "#{NS_L2NW}:l2-network-attributes", klass: L2NetworkAttribute },
        { key: "#{NS_L3NW}:l3-topology-attributes", klass: L3NetworkAttribute }
      ].freeze

      # @param [Hash] data RFC8345 data (network element)
      def initialize(data)
        super(data['network-id'])
        setup_network_types(data)
        setup_nodes(data)
        setup_links(data)
        setup_supports(data, 'supporting-network', SupportingNetwork)
        setup_attribute(data, ATTR_KEY_KLASS_LIST)
      end

      # @param [TpRef] source
      # @param [TpRef] destination
      # @return [Link, nil] Found link (nil if not found)
      def find_link(source, destination)
        @links.find do |link|
          link.source == source && link.destination == destination
        end
      end

      # @param [String] node_ref Source node_ref
      # @param [String] tp_ref Source tp_ref
      # @return [Link, nil] Found link (nil if not found)
      def find_link_by_source(node_ref, tp_ref)
        source_data = {
          'source-node' => node_ref,
          'source-tp' => tp_ref
        }
        source_ref = TpRef.new(source_data, @name)
        @links.find { |link| link.source == source_ref }
      end

      # @param [String] node_ref Source node name
      # @return [Array<Link>] Found links (empty array if not found)
      def find_all_links_by_source_node(node_ref)
        @links.find_all { |link| link.source.node_ref == node_ref }
      end

      # @param [String] node_ref Node name
      # @return [Node, nil] Found node (nil if not found)
      def find_node_by_name(node_ref)
        @nodes.find { |node| node.name == node_ref }
      end

      # @param [Network] other Target network
      # @return [Boolean]
      def eql?(other)
        # TODO: now network types is literal (NOT object)
        super(other) && @network_types == other.network_types
      end

      # @return [String]
      def to_s
        "network:#{@name}"
      end

      # @param [Network] other Network to compare
      # @return [Network] Result of comparison
      def diff(other)
        # forward check
        d_network = Network.new('network-id' => @name)
        # TODO: diff of network-types is not implemented yet
        # now it assumes network-types is same and use self types.
        d_network.network_types = @network_types
        d_network.nodes = diff_forward_check_of(:nodes, other)
        d_network.links = diff_forward_check_of(:links, other)
        d_network.supports = diff_supports(other)
        d_network.attribute = diff_attribute(other)
        d_network.diff_state = select_diff_state(other)
        # backward check
        d_network.diff_backward_check(%i[nodes links supports attribute])
        # return
        d_network
      end

      def fill_diff_state
        fill_diff_state_of(%i[nodes links supports attribute])
      end

      # Convert to data for RFC8345 format
      # @return [Hash]
      def to_data
        data = {
          'network-types' => @network_types,
          'network-id' => @name,
          '_diff_state_' => @diff_state.to_data,
          'node' => @nodes.map(&:to_data),
          "#{NS_TOPO}:link" => @links.map(&:to_data)
        }
        add_supports_and_attr(data, 'supporting-network')
      end

      private

      def setup_network_types(data)
        @network_types = data['network-types'] || {}
      end

      def setup_nodes(data)
        @nodes = []
        return unless data.key?('node')

        @nodes = data['node'].map do |node|
          create_node(node)
        end
      end

      def setup_links(data)
        @links = []
        link_key = "#{NS_TOPO}:link"
        return unless data.key?(link_key)

        @links = data[link_key].map do |link|
          create_link(link)
        end
      end

      def create_node(data)
        Node.new(data, @path)
      end

      def create_link(data)
        Link.new(data, @path)
      end
    end
  end
end
