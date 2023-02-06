# frozen_string_literal: true

require 'netomox/topology/diff_state'
require 'hashdiff'

module Netomox
  module Topology
    # Diff function Mix-in, forward check functions
    # NOTICE: who receive the method? (receiver?)
    # when (a) - (b) => (c)
    module Diffable
      # Diff of supports (for TopoObjectBase)
      # @param [TopoObjectBase] other Target object to compare
      # @return [Array<SupportingRefBase>]
      def diff_supports(other)
        # receiver of this method will be (a), other will be (b)
        diff_list(:supports, other)
      end

      # Diff of attribute (for TopoObjectBase)
      # @param [TopoObjectBase] other Target object to compare
      # @return [AttributeBase]
      def diff_attribute(other)
        # receiver of this method will be (a), other will be (b)
        # NOTICE: (a)(b) can use NULL attribute
        result, d_attr, diff_data = compare_attribute(@attribute, other.attribute)
        arg = { forward: result, pair: @attribute, diff_data: diff_data }
        set_diff_state(d_attr, **arg)
        d_attr
      end

      # Forward diff of attribute
      # @param [Symbol] attr Attribute to check
      # @param [TopoObjectBase] other Target object to compare
      # @return [Array<TopoObjectBase, AttributeBase>]
      def diff_forward_check_of(attr, other)
        # receiver of this method will be (a), other will be (b)
        obj_diff = diff_list(attr, other)
        obj_diff.map do |od|
          if od.diff_state.forward == :kept
            # take diff for kept(or changed) object recursively
            lhs = od.diff_state.pair
            lhs.diff(od)
          else
            # mark all child attr by diff_state itself recursively
            od.fill_diff_state
            od # must return itself
          end
        end
      end

      private

      # @param [AttributeBase] attr Attribute
      # @return [Boolean] true if the attribute has #fill method
      def fillable_attribute?(attr)
        attr.is_a?(AttributeBase) && attr.fill?
      end

      # @param [Array<Symbol>] attrs Attribute key of target object (:supports, :attribute, ...)
      # @return [void]
      def fill_diff_state_of(attrs)
        attrs.each do |attr|
          case send(attr)
          when Array
            fill_array_diff_state(send(attr))
          else
            state_hash = { forward: @diff_state.forward }
            send(attr).fill(state_hash) if fillable_attribute?(send(attr))
            set_diff_state(send(attr), state_hash)
          end
        end
      end

      # @param [Array<TopoObjectBase, AttributeBase>] child_array Array of fillable object
      # @return [void]
      def fill_array_diff_state(child_array)
        child_array.each do |child|
          set_diff_state(child, forward: @diff_state.forward)
          # recursive state marking
          child.fill_diff_state if child.is_a?(TopoObjectBase)
        end
      end

      # rubocop:disable Metrics/AbcSize

      # @param [Symbol] attr Attribute of object to compare
      # @param [TopoObjectBase, AttributeBase] other Target object to compare
      # @return [Array<TopoObjectBase, AttributeBase>] Objects of specified attribute (added DiffState)
      def diff_list(attr, other)
        results = []
        send(attr).each do |lhs|
          rhs = other.send(attr).find { |r| lhs == r }
          # kept when lhs found in rhs or deleted when not found
          results.push(select_diff_list(lhs, rhs))
        end
        other.send(attr).each do |rhs|
          next if send(attr).find { |l| rhs == l }

          # rhs only in other -> added
          diff_data = rhs.is_a?(AttributeBase) ? Hashdiff.diff({}, rhs.to_data) : []
          results.push(set_diff_state(rhs, forward: :added, diff_data: diff_data))
        end
        results
      end
      # rubocop:enable Metrics/AbcSize

      # @param [Symbol] attr Attribute of object to compare
      # @param [TopoObjectBase, AttributeBase] other Target object to compare
      # # @return [TopoObjectBase, AttributeBase] Objects of specified attribute (added DiffState)
      def diff_hash(attr, other)
        lhs = send(attr)
        rhs = other.send(attr)
        result, d_attr, diff_data = compare_attribute(lhs, rhs)
        set_diff_state(d_attr, forward: result, pair: lhs, diff_data: diff_data)
        d_attr
      end

      # Set diff state for list of objects
      # @param [TopoObjectBase, AttributeBase] lhs left-hand-side object
      # @param [TopoObjectBase, AttributeBase] rhs right-hand-side object
      # @return [TopoObjectBase, AttributeBase]
      def select_diff_list(lhs, rhs)
        diff_data = []
        if rhs
          # lhs found in rhs -> kept
          diff_data = Hashdiff.diff(lhs.to_data, rhs.to_data) if lhs.is_a?(AttributeBase) && rhs.is_a?(AttributeBase)
          set_diff_state(rhs, forward: :kept, pair: lhs, diff_data: diff_data)
        else
          # lhs only in self -> deleted
          diff_data = Hashdiff.diff(lhs.to_data, {}) if lhs.is_a?(AttributeBase)
          set_diff_state(lhs, forward: :deleted, diff_data: diff_data)
        end
      end

      # Set diff state and return itself
      # @param [TopoObjectBase, AttributeBase] rlhs right or left hand side of diff
      # @param [Hash] state_hash forward/backward diff state
      # @return [TopoObjectBase, AttributeBase] rlhs itself (added DiffState)
      def set_diff_state(rlhs, state_hash)
        rlhs.diff_state = DiffState.new(**state_hash)
        rlhs
      end

      # rubocop:disable Metrics/AbcSize

      # @param [AttributeBase] lhs
      # @param [AttributeBase] rhs
      # @return [Array<(Symbol, AttributeBase, Array)>] [result-key, object, hash-diff]
      def compare_attribute(lhs, rhs)
        # NOTICE: attribute (lhs and/or rhs) allowed be empty.
        if lhs.empty? && !rhs.empty?
          [:added, rhs, Hashdiff.diff({}, rhs.to_data)]
        elsif !lhs.empty? && rhs.empty?
          [:deleted, lhs, Hashdiff.diff(lhs.to_data, {})]
        elsif Hashdiff.diff(lhs.to_data, rhs.to_data).empty?
          # lhs & rhs are both empty or both exists
          [:kept, rhs, []]
        else
          [:changed, rhs, Hashdiff.diff(lhs.to_data, rhs.to_data)]
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
