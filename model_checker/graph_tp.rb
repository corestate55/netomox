require_relative 'topo_tp'

module TopoChecker
  # Termination point for graph data
  class GraphTerminationPoint < TerminationPoint
    def initialize(data, parent_path)
      super(data, parent_path)
    end

    def n4j_create
      # p "create node, Label:TerminationPoint, id:#{@path}"
      node = termination_point_object
      stps = @supporting_termination_points.map do |stp|
        # p "create relationship, Label:support, id:#{@path},#{stp.ref_path}"
        supporting_tp_object(stp)
      end
      stps.unshift(node)
    end

    private

    def termination_point_object
      {
        object_type: :node,
        labels: [:termination_point],
        property: {
          path: @path
        }
      }
    end

    def supporting_tp_object(stp)
      {
        object_type: :relationship,
        rel_type: :support,
        labels: [],
        property: {
          source: @path,
          destination: stp.ref_path
        }
      }
    end
  end
end
