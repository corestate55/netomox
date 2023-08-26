# frozen_string_literal: true

require 'netomox/const'
require 'netomox/topology/network'
require 'netomox/topology/base'
require 'netomox/topology/error'
require 'netomox/topology/link_tpref'

module Netomox
  module Topology
    # rubocop:disable Metrics/ClassLength

    # Networks for Topology data
    class Networks < TopoObjectBase
      # @!attribute [rw] networks
      #   @return [Array<Network>]
      attr_accessor :networks

      # @return [Hash] RFC8345 data
      def initialize(data)
        super('networks')

        nws_key = "#{NS_NW}:networks"
        return unless data.key?(nws_key)

        setup_networks(data[nws_key])
        setup_diff_state(data[nws_key])
      end

      # @param [String] network_ref Network name
      # @return [Network, nil] Found network (nil if not found)
      def find_network(network_ref)
        @networks.find { |nw| nw.name == network_ref }
      end

      # @param [String] network_type Network type (see const.rb)
      # @return [Array<Network>] Matched networks(layers)
      def find_all_networks_by_type(network_type)
        @networks.find_all do |network|
          network.network_type?(network_type)
        end
      end

      # @param [String] network_ref Network name
      # @param [String] node_ref Node name
      # @return [Node, nil] Found node in network (nil if node is not found)
      # @raise [TopologyElementNotFoundError] If parent network is not found
      def find_node(network_ref, node_ref)
        nw = find_network(network_ref)
        unless nw
          raise TopologyElementNotFoundError,
                "cannot find network:#{network_ref}, parent of node:#{node_ref}"
        end

        nw.nodes.find { |node| node.name == node_ref }
      end

      # @param [String] network_ref Network name
      # @param [String] node_ref Node name
      # @param [String] tp_ref Term-point name
      # @return [TermPoint, nil] Found term-point in node/network (nil if term-point is not found)
      # @raise [TopologyElementNotFoundError] If parent network or node is not found
      def find_tp(network_ref, node_ref, tp_ref)
        node = find_node(network_ref, node_ref)
        unless node
          path = "#{network_ref}__#{node_ref}"
          raise TopologyElementNotFoundError,
                "cannot find node:#{path}, parent of tp:#{tp_ref}"
        end

        node.termination_points.find { |tp| tp.name == tp_ref }
      end

      # @param [SupportingRefBase] support Support object
      # @return [Network, Node, TermPoint, Link, nil] Object the referred support object (nil if not found)
      # @return [StandardError]
      def find_object_by_support(support)
        case support
        when SupportingNetwork
          find_network(support.network_ref)
        when SupportingNode
          find_node(support.network_ref, support.node_ref)
        when SupportingTerminationPoint
          find_tp(support.network_ref, support.node_ref, support.tp_ref)
        when SupportingLink
          find_link(support.network_ref, support.link_ref)
        else
          raise StandardError, 'Unknown support'
        end
      end

      # @param [TpRef] edge Link edge
      # @return [TermPoint, nil] Found term-point
      def find_tp_by_edge(edge)
        find_tp(edge.network_ref, edge.node_ref, edge.tp_ref)
      end

      # @param [String] network_ref Network name
      # @param [String] link_ref Link name
      # @return [Link, nil] Found link in network (nil if link is not found)
      # @raise [TopologyElementNotFoundError] If parent network or link is not found
      def find_link(network_ref, link_ref)
        nw = find_network(network_ref)
        unless nw
          raise TopologyElementNotFoundError,
                "cannot find nw:#{network_ref}, parent of link:#{link_ref}"
        end

        nw.links.find { |link| link.name == link_ref }
      end

      # Find link by its source term point
      # @param [String] network_ref Network name
      # @param [String] node_ref Node name
      # @param [String] tp_ref Term-point name
      # @return [Link, nil] Found link (nil if not found)
      def find_link_source(network_ref, node_ref, tp_ref)
        nw = find_network(network_ref)
        source_data = {
          'source-node' => node_ref,
          'source-tp' => tp_ref
        }
        source_ref = TpRef.new(source_data, network_ref)
        nw.links.find { |link| link.source == source_ref }
      end

      # exec for each node in all networks
      # @yield [node, nw] For each node
      # @yieldparam [Node] node Node
      # @yieldparam [Network] nw Network
      def all_nodes
        @networks.each do |nw|
          nw.nodes.each do |node|
            yield node, nw
          end
        end
      end

      # exec for each link in all networks
      # @yield [link, nw] For each link
      # @yieldparam [Link] link Link
      # @yieldparam [Network] nw Network
      def all_links
        @networks.each do |nw|
          nw.links.each do |link|
            yield link, nw
          end
        end
      end

      # exec for each term-point in all nodes and networks
      # @yield [tp, link, nw] For each term-point
      # @yieldparam [TermPoint] tp Term-point
      # @yieldparam [Node] node Node
      # @yieldparam [Network] nw Network
      def all_termination_points
        all_nodes do |node, nw|
          node.termination_points.each do |tp|
            yield tp, node, nw
          end
        end
      end

      # @param [Networks] other Networks to compare
      # @return [Networks] Result of comparison
      def diff(other)
        # forward check
        d_networks = Networks.new({})
        d_networks.networks = diff_forward_check_of(:networks, other)
        d_networks.diff_state = @diff_state
        # backward check
        d_networks.diff_backward_check(%i[networks])
        # return
        d_networks
      end

      # @return [void]
      def fill_diff_state
        fill_diff_state_of(%i[networks])
      end

      # Convert to data for RFC8345 format
      # @return [Hash]
      def to_data
        {
          "#{NS_NW}:networks" => {
            '_diff_state_' => @diff_state.to_data,
            'network' => @networks.map(&:to_data)
          }
        }
      end

      private

      # @return [void]
      def setup_networks(data)
        @networks = []
        data['network'].each do |each|
          @networks.push create_network(each)
        end
      end

      # @return [Network] network instance
      def create_network(data)
        Network.new(data)
      end

      # @param [Network] network Network
      # @param [TpRef] tp_ref Term-point reference
      # @return [Integer, nil] Term-point reference count (count-up) (nil if the tp not found)
      def ref_count(network, tp_ref)
        tp = find_tp(network.name, tp_ref.node_ref, tp_ref.tp_ref)
        tp&.ref_count_up
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
