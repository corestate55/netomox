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

      # @yield Code block to eval this instance
      # @yieldreturn [void]
      def initialize(&)
        super(nil, 'networks')
        @networks = []
        register(&) if block_given?
      end

      # Add or access network by name
      # @param [String] name Network name
      # @yield Code block to eval the network
      # @yieldreturn [void]
      # @return [Network]
      def network(name, &)
        nw = find_network(name)
        if nw
          nw.register(&) if block_given?
        else
          nw = Network.new(self, name, &)
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
