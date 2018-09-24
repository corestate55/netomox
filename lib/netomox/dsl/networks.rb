require 'netomox/dsl/base'
require 'netomox/dsl/network'

module Netomox
  module DSL
    # multiple network container (top)
    class Networks < DSLObjectBase
      attr_accessor :networks

      def initialize(&block)
        super(nil, 'networks')
        @networks = []
        register(&block) if block_given?
      end

      # find a network and call methods inside it (#register)
      # if network not found, make it.
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

      def topo_data
        networks = @networks.map(&:topo_data)
        { "#{NS_NW}:networks" => { 'network' => networks } }
      end

      def find_network(name)
        @networks.find { |nw| nw.name == name }
      end
    end
  end
end
