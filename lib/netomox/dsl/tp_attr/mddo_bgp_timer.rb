# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # bgp peer timer for MDDO bgp term-point (neighbor) attribute
    class MddoBgpTimer
      # @!attribute [rw] connect_retry
      #   @return [Integer]
      # @!attribute [rw] hold_time
      #   @return [Integer]
      # @!attribute [rw] keepalive_interval
      #   @return [Integer]
      # @!attribute [rw] minimum_advertisement_interval
      #   @return [Integer]
      # @!attribute [rw] restart-time
      #   @return [Integer]
      attr_accessor :connect_retry, :hold_time, :keepalive_interval, :minimum_advertisement_interval, :restart_time

      # @param [Integer] connect_retry
      # @param [Integer] hold_time
      # @param [Integer] keepalive_interval
      # @param [Integer] minimum_advertisement_interval
      # @param [Integer] restart_time
      def initialize(connect_retry: 30, hold_time: 90, keepalive_interval: 30, minimum_advertisement_interval: 30,
                     restart_time: -1)
        @connect_retry = connect_retry
        @hold_time = hold_time
        @keepalive_interval = keepalive_interval
        @minimum_advertisement_interval = minimum_advertisement_interval
        @restart_time = restart_time
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'connect-retry' => @connect_retry,
          'hold-time' => @hold_time,
          'keepalive-interval' => @keepalive_interval,
          'minimum-advertisement-interval' => @minimum_advertisement_interval,
          'restart-time' => @restart_time
        }
      end
    end
  end
end
