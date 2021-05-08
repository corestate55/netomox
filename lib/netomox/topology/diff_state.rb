# frozen_string_literal: true

module Netomox
  module Topology
    # Diff state container
    class DiffState
      attr_accessor :forward, :backward, :pair

      # @param [Symbol] forward Diff state in forward-check
      # @param [Symbol] backward Diff state in backward-check
      # @param [TopoObjectBase] pair Counter-part object to compare
      def initialize(forward: :kept, backward: nil, pair: nil)
        @forward = forward
        @backward = backward
        @pair = pair
      end

      # @return [Symbol] Diff state (:added, :deleted, :kept, :changed)
      def detect
        if %i[added deleted].include?(@forward)
          # add/delete are used only in forward check
          @forward
        elsif [@forward, @backward].include?(:changed)
          :changed
        else
          # when [fwd,bwd] => [:kept, nil] or [:kept, :kept]
          :kept
        end
      end

      # @return [String]
      def to_s
        name = @pair && !@pair.empty? ? @pair.name : ''
        "diff_state: fwd:#{@forward}, bwd:#{@backward}, pair:#{name}"
      end

      # Convert to data for RFC8345 format
      # @return [Hash]
      def to_data
        {
          forward: @forward,
          backward: @backward,
          pair: @pair.nil? ? '' : @pair.path # TODO
        }
      end

      # @return [Boolean]
      def empty?
        !(@forward || @backward || @pair)
      end
    end
  end
end
