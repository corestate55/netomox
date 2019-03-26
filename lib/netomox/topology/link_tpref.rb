require 'netomox/topology/support_base'

module Netomox
  module Topology
    # Termination point reference
    class TpRef < SupportingRefBase
      ATTR_DEFS = [
        { int: :node_ref, ext: 'node-ref' },
        { int: :tp_ref, ext: 'tp-ref' }
      ].freeze
      # NOTICE: Link source/destination (TpRef) has only node_ref and tp_ref
      # according to yang model. but in netomox, it need network_ref
      # to handle TpRef as same manner as other objects.
      attr_accessor :node_ref, :tp_ref, :network_ref

      def initialize(data, parent_path)
        super(ATTR_DEFS, data)
        @network_ref = parent_path
        @node_ref = data['source-node'] || data['dest-node']
        @tp_ref = data['source-tp'] || data['dest-tp']
      end

      def ref_path
        [@network_ref, @node_ref, @tp_ref].join('/')
      end

      def to_data(direction)
        {
          "#{direction}-node" => @node_ref,
          "#{direction}-tp" => @tp_ref,
          '_diff_state_' => @diff_state.to_data
        }
      end

      def ==(other)
        @network_ref == other.network_ref &&
          @node_ref == other.node_ref &&
          @tp_ref == other.tp_ref
      end
    end
  end
end
