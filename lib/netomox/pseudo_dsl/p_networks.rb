# frozen_string_literal: true

require 'netomox/dsl/networks'
require_relative 'p_network'

module Netomox
  module PseudoDSL
    # pseudo networks: Netomox-DSL interpreter
    class PNetworks
      extend Forwardable

      def_delegators :@networks, :each, :find, :push, :[]

      # @!attribute [rw] networks
      #   @return [Array<PNetwork>]
      # @!attribute [rw] nmx_networks
      #   @return [Netomox::DSL::Networks]
      attr_accessor :networks, :nmx_networks

      def initialize
        @networks = [] # Array<PNetwork>
        @nmx_networks = Netomox::DSL::Networks.new
      end

      # Find or create new network
      # @param [String] network_name Name of the network
      def network(network_name)
        found_nw = find_network_by_name(network_name)
        return found_nw if found_nw

        new_nw = PNetwork.new(network_name)
        @networks.push(new_nw)
        new_nw
      end

      # convert to Netomox::DSL objects
      # @return [Netomox::DSL::Networks]
      def interpret
        @networks.each { |network| interpret_network(network) }
        @nmx_networks
      end

      # @param [String] network_name Name of a network
      # @return [PNetwork, nil] network if found (nil if not found)
      def find_network_by_name(network_name)
        @networks.find { |nw| nw.name == network_name }
      end

      # Print data to stderr
      # @return [void]
      def dump
        @networks.each(&:dump)
      end

      private

      # @param [PNetwork] network A network to convert Netomox::DSL::Network
      # @return [Netomox::DSL::Network] converted network object
      def make_nmx_network(network)
        nmx_network = @nmx_networks.network(network.name)
        unless nmx_network
          Netomox.logger.error "Network: #{network.name} not found"
          return
        end

        nmx_network.attribute(network.attribute) if network.attribute
        nmx_network.type(network.type) if network.type
        nmx_network
      end

      # @param [PNetwork] network A network to convert netomox::DSL::Network
      # @return [void]
      def interpret_network(network)
        nmx_network = make_nmx_network(network)
        nmx_network.attribute(network.attribute) if network.attribute
        network.supports.each { |s| nmx_network.support(s) }
        network.nodes.each { |node| interpret_node(node, nmx_network) }
        network.links.each { |link| interpret_link(link, nmx_network) }
      end

      # @param [PTermPoint] term_point A term-point to convert to Netomox::DSL::TermPoint
      # @param [Netomox::DSL::Node] nmx_node Parent node object of the term-point
      # @return [void]
      def interpret_tp(term_point, nmx_node)
        nmx_tp = nmx_node.tp(term_point.name)
        nmx_tp.attribute(term_point.attribute) if term_point.attribute
        term_point.supports.each { |s| nmx_tp.support(s) }
      end

      # @param [PNode] node A node to convert to Netomox::DSL::Node
      # @param [Netomox::DSL::Network] nmx_network Parent network object of the node
      # @return [void]
      def interpret_node(node, nmx_network)
        nmx_node = nmx_network.node(node.name)
        nmx_node.attribute(node.attribute) if node.attribute
        node.supports.each { |s| nmx_node.support(s) }
        node.tps.each { |tp| interpret_tp(tp, nmx_node) }
      end

      # @param [PLink] link A link to convert to Netomox::DSL::Link
      # @param [Netomox::DSL::Network] nmx_network Parent network object of the link
      # @return [void]
      def interpret_link(link, nmx_network)
        nmx_network.link(link.src.node, link.src.tp, link.dst.node, link.dst.tp)
      end
    end
  end
end
