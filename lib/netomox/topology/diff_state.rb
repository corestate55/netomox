# frozen_string_literal: true

module Netomox
  module Topology
    # Diff state container
    class DiffState
      attr_accessor :forward, :backward, :pair, :diff_data

      # @param [Symbol] forward Diff state in forward-check
      # @param [Symbol] backward Diff state in backward-check
      # @param [TopoObjectBase] pair Counter-part object to compare
      def initialize(forward: :kept, backward: nil, pair: nil, diff_data: nil)
        @forward = forward
        @backward = backward
        @pair = pair
        @diff_data = diff_data
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
        data = {
          forward: @forward,
          backward: @backward,
          pair: @pair.nil? || @pair.empty? ? '' : @pair.path # TODO
        }
        # diff_data is optional
        data[:diff_data] = @diff_data unless @diff_data.nil? || @diff_data.empty?
        data
      end

      def kept?
        detect == :kept
      end

      # @return [Boolean]
      def empty?
        !(@forward || @backward || @pair)
      end
    end
  end
end
