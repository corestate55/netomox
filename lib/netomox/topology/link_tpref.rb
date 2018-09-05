require 'netomox/topology/support_base'

module Netomox
  module Topology
    # Termination point reference
    class TpRef < SupportingRefBase
      ATTR_DEFS = [
        { int: :node_ref, ext: 'node-ref' },
        { int: :tp_ref, ext: 'tp-ref' }
      ].freeze
      attr_accessor :node_ref, :tp_ref

      def initialize(data)
        super(ATTR_DEFS, data)
        @node_ref = data['source-node'] || data['dest-node']
        @tp_ref = data['source-tp'] || data['dest-tp']
      end

      def to_data(direction)
        {
          "#{direction}-node" => @node_ref,
          "#{direction}-tp" => @tp_ref,
          '_diff_state_' => @diff_state.to_data
        }
      end
    end
  end
end
