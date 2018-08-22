require_relative 'topo_networks_ops'

module TopoChecker
  # Networks for Topology data (diff function)
  class Networks < TopoObjectBase
    def diff(other)
      d_nws = Networks.new({})
      nws_diff = diff_list(:networks, other)
      d_nws.networks = nws_diff.map do |nd|
        if nd.diff_state.forward == :kept
          nd.diff(nd.diff_state.pair)
        else
          nd
        end
      end
      d_nws
    end
  end
end
