require_relative 'graph_network'
require_relative 'topo_networks'

module TopoChecker
  # Networks for graph data
  class GraphNetworks < Networks
    attr_reader :objects

    def initialize(data)
      super(data)
      @objects = []
      make_neo4j_objects
      config_neo4j
    end

    def node_objects
      @objects.find_all { |obj| obj[:object_type] == :node }
    end

    def relationship_objects
      @objects.find_all { |obj| obj[:object_type] == :relationship }
    end

    private

    def make_neo4j_objects
      n4j_create_for_all_networks
      n4j_create_for_all_nodes
      n4j_create_for_all_tps
      n4j_create_for_all_links
    end

    def n4j_create_for_all_networks
      all_networks do |nw|
        @objects.concat(nw.n4j_create)
      end
    end

    def n4j_create_for_all_nodes
      all_nodes do |node, nw|
        @objects.concat(node.n4j_create)
        # p "create relationship,
        # Label:constructed_with, id:#{nw.path},#{node.path}"
        @objects.push(network_to_node_relation(node, nw))
      end
    end

    def network_to_node_relation(node, network)
      {
        object_type: :relationship,
        rel_type: :constructed_with,
        labels: [],
        property: {
          source: network.path,
          destination: node.path
        }
      }
    end

    def n4j_create_for_all_tps
      all_termination_points do |tp, node, _nw|
        @objects.concat(tp.n4j_create)
        # p "create relationship, Label:has, id:#{node.path},#{tp.path}"
        @objects.push(node_tp_relation(tp, node))
      end
    end

    def node_tp_relation(term_point, node)
      {
        object_type: :relationship,
        rel_type: :has,
        labels: [],
        property: {
          source: node.path,
          destination: term_point.path
        }
      }
    end

    def n4j_create_for_all_links
      all_links do |link, _nw|
        @objects.push(link.n4j_create)
      end
    end

    def create_network(data)
      GraphNetwork.new(data)
    end
  end
end
