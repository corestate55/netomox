require_relative 'topo_support_base'

module TopoChecker
  # Supporting network for network topology data
  class SupportingNetwork < SupportingRefBase
    ATTRS = [:network_ref].freeze
    attr_reader(*ATTRS)

    def initialize(data)
      super(:nw_ref, ATTRS)
      @network_ref = data['network-ref']
    end
  end
end
