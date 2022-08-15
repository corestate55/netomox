# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # Redistribute config for MDDO ospf-area node attribute
    class MddoOspfRedistribute
      # @!attribute [rw] protocol
      #   @return [String] TODO: enum{static, connected}
      # @!attribute [rw] metric_type
      #   @return [Integer] enum{1, 2} (OE1, OE2)
      attr_accessor :protocol, :metric_type

      # @param [String] protocol
      # @param [Integer] metric_type
      def initialize(protocol: 'connected', metric_type: 2)
        @protocol = protocol
        @metric_type = metric_type
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'protocol' => @protocol,
          'metric-type' => @metric_type
        }
      end
    end
  end
end
