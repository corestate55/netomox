require_relative 'topo_const'
require_relative 'topo_support_tp'
require_relative 'topo_tp_attr'
require_relative 'topo_base'

module TopoChecker
  # Termination point for topology data
  class TerminationPoint < TopoObjectBase
    attr_reader :ref_count

    def initialize(data, parent_path)
      super(data['tp-id'], parent_path)
      @ref_count = 0
      setup_supports(data, 'supporting-termination-point', SupportingTerminationPoint)
      setup_attribute(data, [
        { key: "#{NS_L2NW}:l2-termination-point-attributes", klass: L2TPAttribute },
        { key: "#{NS_L3NW}:l3-termination-point-attributes", klass: L3TPAttribute }
      ])
    end

    def to_s
      "term_point:#{@name}"
    end

    def diff(other)
      d_tp = TerminationPoint.new({'tp-id' => @name}, @parent_path)
      d_tp.supports = diff_supports(other)
      d_tp.attribute = diff_attribute(other)
      d_tp.diff_state = @diff_state
      d_tp
    end

    def ref_count_up
      @ref_count += 1
    end

    def irregular_ref_count?
      @ref_count.zero? || @ref_count.odd? || @ref_count >= 4
    end
  end
end
