require 'netomox/graphdb/node'
require 'netomox/graphdb/link'
require 'netomox/topology/network'

module Netomox
  module GraphDB
    # Network for graph data
    class Network < Topology::Network
      def initialize(data)
        super(data)
      end

      def n4j_create
        # p "create node, Label:network, id:#{@path}"
        node = network_object
        snws = @supports.map do |snw|
          # p "create relationship, Label:support, id:#{@path},#{snw.ref_path}"
          supporting_network_object(snw)
        end
        snws.unshift(node)
      end

      private

      def network_object
        {
          object_type: :node,
          labels: [:network],
          property: {
            path: @path
          }
        }
      end

      def supporting_network_object(snw)
        {
          object_type: :relationship,
          rel_type: :support,
          labels: [],
          property: {
            source: @path,
            destination: snw.ref_path
          }
        }
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
