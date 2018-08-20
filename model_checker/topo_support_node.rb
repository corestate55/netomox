require_relative 'topo_support_base'

module TopoChecker
  # Supporting node for topology node
  class SupportingNode < SupportingRefBase
    ATTRS = %i[network_ref node_ref].freeze
    attr_reader(*ATTRS)

    def initialize(data)
      super(:node_ref, ATTRS)
      @network_ref = data['network-ref']
      @node_ref = data['node-ref']
    end
  end
end
