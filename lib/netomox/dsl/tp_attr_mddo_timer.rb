# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # ospf timer for MDDO ospf-area term-point attribute
    class MddoOspfAreaTimer
      # @!attribute [rw] hello_interval
      #   @return [Integer]
      # @!attribute [rw] dead_interval
      #   @return [Integer]
      # @!attribute retransmission_interval
      #   @return [Integer]
      attr_accessor :hello_interval, :dead_interval, :retransmission_interval

      # @param [Integer] hello_interval
      # @param [Integer] dead_interval
      # @param [Integer] retransmission_interval
      def initialize(hello_interval: 10, dead_interval: 40, retransmission_interval: 5)
        @hello_interval = hello_interval
        @dead_interval = dead_interval
        @retransmission_interval = retransmission_interval
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'hello-interval' => @hello_interval,
          'dead-interval' => @dead_interval,
          'retransmission-interval' => @retransmission_interval
        }
      end
    end
  end
end
