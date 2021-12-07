# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # prefix info for L3 node attribute
    class L3Prefix
      # @!attribute [rw] prefix
      #   @return [String]
      # @!attribute [rw] metric
      #   @return [Integer]
      # @!attribute [rw] flag
      #   @return [Array<String>]
      attr_accessor :prefix, :metric, :flag

      # @param [String] prefix
      # @param [Integer] metric
      # @param [Array<String>] flag
      def initialize(prefix: '', metric: 10, flag: [])
        @prefix = prefix
        @metric = metric
        @flag = flag
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'prefix' => @prefix,
          'metric' => @metric,
          'flag' => @flag
        }
      end
    end
  end
end
