# frozen_string_literal: true

require 'netomox/const'
require 'netomox/topology/support_base'
require 'netomox/topology/tp_attr_rfc'
require 'netomox/topology/tp_attr_mddo'
require 'netomox/topology/base'

module Netomox
  module Topology
    # Termination point for topology data
    class TermPoint < TopoObjectBase
      attr_reader :ref_count

      # Attribute type key and its class for TermPoint
      ATTR_KEY_KLASS_LIST = [
        { key: "#{NS_L2NW}:l2-termination-point-attributes", klass: L2TPAttribute },
        { key: "#{NS_L3NW}:l3-termination-point-attributes", klass: L3TPAttribute },
        { key: "#{NS_MDDO}:l1-termination-point-attributes", klass: MddoL1TPAttribute },
        { key: "#{NS_MDDO}:l2-termination-point-attributes", klass: MddoL2TPAttribute },
        { key: "#{NS_MDDO}:l3-termination-point-attributes", klass: MddoL3TPAttribute }
      ].freeze

      # @param [Hash] data RFC8345 data (term-point element)
      # @param [String] parent_path Parent (node) path
      def initialize(data, parent_path)
        super(data['tp-id'], parent_path)

        @ref_count = 0
        key = 'supporting-termination-point'.freeze # alias
        setup_supports(data, key, SupportingTerminationPoint)
        setup_attribute(data, ATTR_KEY_KLASS_LIST)
        setup_diff_state(data)
      end

      # @return [String]
      def to_s
        "term_point:#{@name}"
      end

      # Convert to data for RFC8345 format
      # @return [Hash]
      def to_data
        data = {
          'tp-id' => @name,
          '_diff_state_' => @diff_state.to_data
        }
        add_supports_and_attr(data, 'supporting-termination-point')
      end

      # @param [TermPoint] other Term-point to compare
      # @return [TermPoint] Result of comparison
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

      # @return [Integer]
      def ref_count_up
        @ref_count += 1
      end

      # Is reference count normal?
      # @return [Boolean]
      def regular_ref_count?
        !(@ref_count.zero? || @ref_count.odd? || @ref_count >= 4)
      end
    end
  end
end
