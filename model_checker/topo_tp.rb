require_relative 'topo_const'
require_relative 'topo_support_base'
require_relative 'topo_tp_attr'
require_relative 'topo_base'

module TopoChecker
  # Termination point for topology data
  class TerminationPoint < TopoObjectBase
    attr_reader :ref_count

    def initialize(data, parent_path)
      super(data['tp-id'], parent_path)
      @ref_count = 0
      key = 'supporting-termination-point' # alias
      setup_supports(data, key, SupportingTerminationPoint)
      key = 'termination-point-attributes' # alias
      key_klass_list = [
        { key: "#{NS_L2NW}:l2-#{key}", klass: L2TPAttribute },
        { key: "#{NS_L3NW}:l3-#{key}", klass: L3TPAttribute }
      ]
      setup_attribute(data, key_klass_list)
    end

    def to_s
      "term_point:#{@name}"
    end

    def to_data
      {
        'tp-id' => @name,
        '_diff_state_' => @diff_state.to_data,
        'supporting-termination-point' => @supports.map(&:to_data),
        @attribute.type => @attribute.to_data
      }
    end

    def diff(other)
      # forward check
      d_tp = TerminationPoint.new({ 'tp-id' => @name }, @parent_path)
      d_tp.supports = diff_supports(other)
      d_tp.attribute = diff_attribute(other)
      d_tp.diff_state = @diff_state
      # backward check
      d_tp.diff_backward_check(%i[supports attribute])
      # return
      d_tp
    end

    def fill_diff_state
      fill_diff_state_of(%i[supports attribute])
    end

    def ref_count_up
      @ref_count += 1
    end

    def irregular_ref_count?
      @ref_count.zero? || @ref_count.odd? || @ref_count >= 4
    end
  end
end
