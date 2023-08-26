# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # bgp timer for MDDO bgp term-point attribute
    class MddoBgpTimer < SubAttributeBase
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

      # Attribute definition of bgp timer
      ATTR_DEFS = [
        { int: :connect_retry, ext: 'connect-retry', default: 30 },
        { int: :hold_time, ext: 'hold-time', default: 90 },
        { int: :keepalive_interval, ext: 'keepalive-interval', default: 30 },
        { int: :minimum_advertisement_interval, ext: 'minimum-advertisement-interval', default: 30 },
        { int: :restart_time, ext: 'restart-time', default: -1 }
      ].freeze

      include Diffable

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "bgp-timer: con_retry:#{connect_retry}, hold:#{hold_time}, keepalive:#{keepalive_interval}"
      end
    end
  end
end
