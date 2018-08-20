require_relative 'topo_node'
require_relative 'graph_tp'

module TopoChecker
  # Node for graph data
  class GraphNode < Node
    def initialize(data, parent_path)
      super(data, parent_path)
    end

    def n4j_create
      # p "create node, Label:Node, id:#{@path}"
      node = node_object
      snodes = @supports.map do |snode|
        # p "create relationship, Label:support, id:#{@path},#{snode.ref_path}"
        supporting_node_object(snode)
      end
      snodes.unshift(node)
    end

    private

    def node_object
      {
        object_type: :node,
        labels: [:node],
        property: {
          path: @path
        }
      }
    end

    def supporting_node_object(snode)
      {
        object_type: :relationship,
        rel_type: :support,
        labels: [],
        property: {
          source: @path,
          destination: snode.ref_path
        }
      }
    end

    def create_termination_point(data)
      GraphTerminationPoint.new(data, @path)
    end
  end
end
