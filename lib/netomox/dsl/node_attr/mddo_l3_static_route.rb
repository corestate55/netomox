# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # Static routes for MDDO L3 node attribute
    class MddoL3StaticRoute
      # @!attribute [rw] prefix
      #   @return [String] IP address/prefix-length
      # @!attribute [rw] next_hop
      #   @return [String] IP address
      # @!attribute [rw] interface
      #   @return [String] interface (device) name
      # @!attribute [rw] metric
      #   @return [Integer]
      # @!attribute [rw] preference
      #   @return [Integer]
      # @!attribute [rw] description
      #   @return [String]
      attr_accessor :prefix, :next_hop, :interface, :metric, :preference, :description

      # rubocop:disable Metrics/ParameterLists
      # @param [String] prefix
      # @param [String] next_hop
      # @param [String] interface
      # @param [Integer] metric
      # @param [Integer] preference
      # @param [String] description
      def initialize(prefix: '', next_hop: '', interface: '', metric: 10, preference: 1, description: '')
        @prefix = prefix
        @next_hop = next_hop
        @interface = interface
        @metric = metric
        @preference = preference
        @description = description
      end
      # rubocop:enable Metrics/ParameterLists

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'prefix' => @prefix,
          'next-hop' => @next_hop,
          'interface' => @interface,
          'metric' => @metric,
          'preference' => @preference,
          'description' => @description
        }
      end
    end
  end
end
