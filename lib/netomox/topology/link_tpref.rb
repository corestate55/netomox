# frozen_string_literal: true

require 'netomox/topology/support_base'

module Netomox
  module Topology
    # Termination point reference
    class TpRef < SupportingRefBase
      # NOTICE: Link source/destination (TpRef) has only node_ref and tp_ref
      # according to yang model. but in netomox, it need network_ref
      # to handle TpRef as same manner as other objects.
      #
      # @!attribute [rw] network_ref
      #   @return [String]
      # @!attribute [rw] node_ref
      #   @return [String]
      # @!attribute [rw] tp_ref
      #   @return [String]
      attr_accessor :network_ref, :node_ref, :tp_ref

      # Attribute definition of term-point reference
      ATTR_DEFS = [
        { int: :node_ref, ext: 'node-ref' },
        { int: :tp_ref, ext: 'tp-ref' }
      ].freeze

      # @param [Hash] data RFC8345 data (link source/destination element)
      # @param [String] parent_path Parent (link) path
      def initialize(data, parent_path)
        super(ATTR_DEFS, data)
        @network_ref = parent_path
        @node_ref = data['source-node'] || data['dest-node']
        @tp_ref = data['source-tp'] || data['dest-tp']
      end

      # @return [Array<String>]
      def refs
        [@network_ref, @node_ref, @tp_ref]
      end

      # @return [String]
      def ref_path
        refs.join('__')
      end

      # Convert to data for RFC8345 format
      # @return [Hash]
      def to_data(direction)
        {
          "#{direction}-node" => @node_ref,
          "#{direction}-tp" => @tp_ref,
          '_diff_state_' => @diff_state.to_data
        }
      end

      # @param [TpRef] other Target term-point-ref
      # @return [Boolean]
      def ==(other)
        @network_ref == other.network_ref &&
          @node_ref == other.node_ref &&
          @tp_ref == other.tp_ref
      end
    end
  end
end
