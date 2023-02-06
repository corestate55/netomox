# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # ospf neighbor for MDDO ospf-area term-point attribute
    class MddoOspfNeighbor
      # @!attribute [rw] router_id
      #   @return [String]
      # @!attribute [rw] ip_addr
      #   @return [String]
      attr_accessor :router_id, :ip_addr

      # @param [String] router_id
      # @param [String] ip_addr
      def initialize(router_id: '', ip_addr: '')
        @router_id = router_id
        @ip_addr = ip_addr
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'router-id' => @router_id,
          'ip-address' => @ip_addr
        }
      end
    end
  end
end
