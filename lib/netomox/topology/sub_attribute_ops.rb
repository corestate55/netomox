# frozen_string_literal: true

module Netomox
  module Topology
    # Module to mix-in for attribute that has sub-attribute
    module SubAttributeOps
      # @param [Symbol] attr Attribute key
      # @param [AttributeBase] other Attribute to compare
      # @return [AttributeBase]
      def diff_of(attr, other)
        return diff_with_empty_attr unless other.diff?

        if whole_added?(send(attr), other.send(attr))
          other.fill(forward: :added)
        elsif whole_deleted?(send(attr), other.send(attr))
          fill(forward: :deleted)
        elsif send(attr).is_a?(Array)
          d_vid_names = diff_list(attr, other) # NOTICE: with Diffable mix-in
          other.send("#{attr}=", d_vid_names)
        else
          diff_hash(attr, other)
        end
        other
      end

      # @param [Symbol] attr Attribute key
      # @param [Hash] state_hash Hash of diff-state
      # @return [void]
      def fill_of(attr, state_hash)
        target_attr = send(attr)
        if target_attr.is_a?(Array)
          send(attr).each { |vid_name| set_diff_state(vid_name, state_hash) }
        else
          set_diff_state(target_attr, state_hash)
        end
      end

      private

      # @param [AttributeBase] lhs Left-hand-side attribute
      # @param [AttributeBase] rhs Right-hand-side attribute
      # @return [Boolean] true if lhs is empty and rhs is not empty (added)
      def whole_added?(lhs, rhs)
        lhs.empty? && !rhs.empty?
      end

      # @param [AttributeBase] lhs Left-hand-side attribute
      # @param [AttributeBase] rhs Right-hand-side attribute
      # @return [Boolean] true if lhs is not empty and rhs is empty (deleted)
      def whole_deleted?(lhs, rhs)
        !lhs.empty? && rhs.empty?
      end

      # @return [AttributeBase] self
      def diff_with_empty_attr
        # when other = AttributeBase (EMPTY Attribute)
        state = { forward: :deleted }
        fill(state)
        @diff_state = DiffState.new(**state)
        self
      end
    end
  end
end
