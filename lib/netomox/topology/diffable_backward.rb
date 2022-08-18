# frozen_string_literal: true

require 'netomox/topology/diff_state'

module Netomox
  module Topology
    # Diff function Mix-in, backward check funcitons
    # NOTICE: who receive the method? (receiver?)
    # when (a) - (b) => (c)
    module Diffable
      # @param [Array<Symbol>] attrs Attributes
      # @return [void]
      def diff_backward_check(attrs)
        # receiver of this method will be (c)
        bwd_states = []
        attrs.each do |attr|
          bwd_states.push(pick_backward_state(send(attr)))
        end
        @diff_state.backward = backward_state_from(bwd_states)
      end

      private

      # @param [TopoObjectBase, AttributeBase] child_obj Sub-attribute object
      # @return [:Symbol, Array<Symbol>, nil] Symbol(s) of the child_obj
      def pick_backward_state(child_obj)
        case child_obj
        when Array
          return nil if child_obj.empty? # nil for empty list

          child_obj.map { |d| d.diff_state.detect }
        else
          child_obj.diff_state.detect
        end
      end

      # @param [Array<Symbol, nil>] diff_states Forward-states of child/children
      # @return [Symbol] Backward-state
      def backward_state_from(diff_states)
        states = diff_states.flatten
        states.delete(nil) # del nil as empty list
        if states.all?(:kept)
          :kept
        else
          :changed
        end
      end

      # @param [TopoObjectBase] other Object to compare
      # @return [DiffState] Diff state
      def select_diff_state(other)
        if eql?(other)
          @diff_state
        else
          DiffState.new(forward: :changed)
        end
      end
    end
  end
end
