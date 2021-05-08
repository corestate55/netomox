# frozen_string_literal: true

require 'netomox/dsl/base'
require 'netomox/dsl/network'

module Netomox
  module DSL
    # multiple network container (top)
    class Networks < DSLObjectBase
      # @!attribute [rw] networks
      #   @return [Array<Network>]
      attr_accessor :networks

      # @param [Proc] block Code block to eval this instance
      def initialize(&block)
        super(nil, 'networks')
        @networks = []
        register(&block) if block_given?
      end

      # Add or access network by name
      # @param [String] name Network name
      # @param [Proc] block Code block to eval the network
      # @return [Network]
      def network(name, &block)
        nw = find_network(name)
        if nw
          nw.register(&block) if block_given?
        else
          nw = Network.new(self, name, &block)
          @networks.push(nw)
        end
        nw
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        networks = @networks.map(&:topo_data)
        { "#{NS_NW}:networks" => { 'network' => networks } }
      end

      # Find network by name
      # @param [String] name Network name
      # @return [Network, nil] Found network (nil if not found)
      def find_network(name)
        @networks.find { |nw| nw.name == name }
      end
    end
  end
end
