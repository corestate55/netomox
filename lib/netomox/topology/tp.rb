require 'netomox/const'
require 'netomox/topology/support_base'
require 'netomox/topology/tp_attr'
require 'netomox/topology/base'

module Netomox
  module Topology
    # Termination point for topology data
    class TermPoint < TopoObjectBase
      attr_reader :ref_count

      ATTR_KEY_KLASS_LIST = [
        {
          key: "#{NS_L2NW}:l2-termination-point-attributes",
          klass: L2TPAttribute
        },
        {
          key: "#{NS_L3NW}:l3-termination-point-attributes",
          klass: L3TPAttribute
        }
      ].freeze

      def initialize(data, parent_path)
        super(data['tp-id'], parent_path)
        @ref_count = 0
        key = 'supporting-termination-point' # alias
        setup_supports(data, key, SupportingTerminationPoint)
        setup_attribute(data, ATTR_KEY_KLASS_LIST)
      end

      def to_s
        "term_point:#{@name}"
      end

      def to_data
        data = {
          'tp-id' => @name,
          '_diff_state_' => @diff_state.to_data
        }
        add_supports_and_attr(data, 'supporting-termination-point')
      end

      def diff(other)
        # forward check
        d_tp = TermPoint.new({ 'tp-id' => @name }, @parent_path)
        d_tp.supports = diff_supports(other)
        d_tp.attribute = diff_attribute(other)
        d_tp.diff_state = select_diff_state(other)
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

      def regular_ref_count?
        !(@ref_count.zero? || @ref_count.odd? || @ref_count >= 4)
      end
    end
  end
end
