require_relative 'topo_tp'

module TopoChecker
  # Node for topology data
  class Node
    attr_reader :name, :path, :termination_points, :supporting_nodes

    # Supporting node for topology node
    class SupportingNode
      attr_reader :network_ref, :node_ref

      def initialize(data)
        @network_ref = data['network-ref']
        @node_ref = data['node-ref']
      end

      def to_s
        "node_ref:#{@network_ref}/#{@node_ref}"
      end

      def ref_path
        [@network_ref, @node_ref].join('/')
      end
    end

    def initialize(data, parent_path)
      @name = data['node-id']
      @path = [parent_path, @name].join('/')
      setup_termination_points(data)

      @supporting_nodes = []
      return unless data.key?('supporting-node')
      @supporting_nodes = data['supporting-node'].map do |snode|
        SupportingNode.new(snode)
      end
    end

    private

    def setup_termination_points(data)
      @termination_points = []
      tp_key = 'ietf-network-topology:termination-point' # alias
      @termination_points = data[tp_key].map do |tp|
        create_termination_point(tp)
      end
    end

    def create_termination_point(data)
      TerminationPoint.new(data, @path)
    end
  end
end
