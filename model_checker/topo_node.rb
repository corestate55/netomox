require_relative 'topo_const'
require_relative 'topo_tp'
require_relative 'topo_support_node'
require_relative 'topo_node_attr'
require_relative 'topo_diff'
require_relative 'topo_object_base'

module TopoChecker
  # Node for topology data
  class Node < TopoObjectBase
    attr_reader :termination_points
    include TopoDiff

    def initialize(data, parent_path)
      super(data['node-id'], parent_path)
      setup_termination_points(data)
      setup_supports(data, 'supporting-node', SupportingNode)
      setup_attribute(data,[
        {key: "#{NS_L2NW}:l2-node-attributes", klass: L2NodeAttribute },
        {key: "#{NS_L3NW}:l3-node-attributes", klass: L3NodeAttribute }
      ])
    end

    def -(other)
      diff_tp(other)
      diff_supports(other)
      diff_attribute(other)
    end

    def to_s
      "node:#{@name}"
    end

    private

    def diff_tp(other)
      diff_table = diff_list(:termination_points, other)
      print_diff_list(:termination_points, diff_table)
      diff_kept(:termination_points, diff_table, other)
    end

    def setup_termination_points(data)
      @termination_points = []
      @termination_points = data["#{NS_TOPO}:termination-point"].map do |tp|
        create_termination_point(tp)
      end
    end

    def create_termination_point(data)
      TerminationPoint.new(data, @path)
    end
  end
end
