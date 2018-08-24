require_relative 'topo_const'
require_relative 'topo_tp'
require_relative 'topo_support_node'
require_relative 'topo_node_attr'
require_relative 'topo_base'

module TopoChecker
  # Node for topology data
  class Node < TopoObjectBase
    attr_accessor :termination_points

    def initialize(data, parent_path)
      super(data['node-id'], parent_path)
      setup_termination_points(data)
      setup_supports(data, 'supporting-node', SupportingNode)
      key_klass_list = [
        { key: "#{NS_L2NW}:l2-node-attributes", klass: L2NodeAttribute },
        { key: "#{NS_L3NW}:l3-node-attributes", klass: L3NodeAttribute }
      ]
      setup_attribute(data, key_klass_list)
    end

    def diff(other)
      # forward check
      d_node = Node.new({ 'node-id' => @name }, @parent_path)
      d_tp = diff_list(:termination_points, other)
      d_node.termination_points = d_tp.map do |dt|
        if dt.diff_state.forward == :kept
          dt.diff(dt.diff_state.pair)
        else
          dt
        end
      end
      d_node.supports = diff_supports(other)
      d_node.attribute = diff_attribute(other)
      d_node.diff_state = @diff_state

      # backward check
      diff_states = []
      %i[termination_points supports attribute].each do |attr|
        case d_node.send(attr)
        when Array then
          next if d_node.send(attr).empty? # TODO: OK?
          diff_states.push(d_node.send(attr).map { |d| d.diff_state.forward })
        else
          diff_states.push(d_node.send(attr).diff_state.forward)
        end
      end

      d_node.diff_state.backward = if diff_states.flatten.all?(:kept)
                                     :kept
                                   else
                                     :changed
                                   end

      # return
      d_node
    end

    def to_s
      "node:#{@name}"
    end

    def to_data
      {
        'node-id' => @name,
        '_diff_state_' => @diff_state.to_data,
        "#{NS_TOPO}:termination-point" => @termination_points.map(&:to_data),
        'supporting-node' => @supports.map(&:to_data),
        'node-attributes' => @attribute.to_data
      }
    end

    private

    def setup_termination_points(data)
      @termination_points = []
      tp_key = "#{NS_TOPO}:termination-point"
      return unless data.key?("#{NS_TOPO}:termination-point")
      @termination_points = data[tp_key].map do |tp|
        create_termination_point(tp)
      end
    end

    def create_termination_point(data)
      TerminationPoint.new(data, @path)
    end
  end
end
