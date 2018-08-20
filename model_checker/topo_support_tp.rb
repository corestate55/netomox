require_relative 'topo_support_base'

module TopoChecker
  # Supporting termination point for topology termination point
  class SupportingTerminationPoint < SupportingRefBase
    ATTRS = %i[network_ref node_ref tp_ref].freeze
    attr_reader(*ATTRS)

    def initialize(data)
      super(:tp_ref, ATTRS)
      @network_ref = data['network-ref']
      @node_ref = data['node-ref']
      @tp_ref = data['tp-ref']
    end
  end
end
