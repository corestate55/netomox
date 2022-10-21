# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # ospf time for MDDO ospf-area term-point attribute
    class MddoOspfTimer < SubAttributeBase
      # @!attribute [rw] hello_interval
      #   @return [Integer]
      # @!attribute [rw] dead_interval
      #   @return [Integer]
      # @!attribute retransmission_interval
      #   @return [Integer]
      attr_accessor :hello_interval, :dead_interval, :retransmission_interval

      # Attribute definition of ospf timer
      ATTR_DEFS = [
        { int: :hello_interval, ext: 'hello-interval', default: 10 },
        { int: :dead_interval, ext: 'dead-interval', default: 40 },
        { int: :retransmission_interval, ext: 'retransmission-interval', default: 5 }
      ].freeze

      include Diffable

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "ospf-timer: hello:#{hello_interval}, dead:#{dead_interval}, retransmission:#{retransmission_interval}"
      end
    end
  end
end
