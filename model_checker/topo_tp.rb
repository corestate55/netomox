require_relative 'topo_const'
require_relative 'topo_support_tp'
require_relative 'topo_tp_attr'
require_relative 'topo_diff'
require_relative 'topo_object_base'

module TopoChecker
  # Termination point for topology data
  class TerminationPoint < TopoObjectBase
    attr_reader :ref_count
    include TopoDiff

    def initialize(data, parent_path)
      super(data['tp-id'], parent_path)
      @ref_count = 0
      setup_supports(data, 'supporting-termination-point', SupportingTerminationPoint)
      setup_attribute(data, [
        { key: "#{NS_L2NW}:l2-termination-point-attributes", klass: L2TPAttribute },
        { key: "#{NS_L3NW}:l3-termination-point-attributes", klass: L3TPAttribute }
      ])
    end

    def eql?(other)
      @name == other.name
    end

    def to_s
      "term_point:#{@name}"
    end

    def -(other)
      diff_supports(other)
      diff_attribute(other)
    end

    def ref_count_up
      @ref_count += 1
    end

    def irregular_ref_count?
      @ref_count.zero? || @ref_count.odd? || @ref_count >= 4
    end
  end
end
