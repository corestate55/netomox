require_relative 'topo_networks_ops'

module TopoChecker
  # Networks for Topology data (diff function)
  class Networks < TopoObjectBase
    def diff(other)
      # forward check
      d_networks = Networks.new({})
      d_networks.networks = diff_forward_check_of(:networks, other)
      d_networks.diff_state = @diff_state
      # backward check
      d_networks.diff_backward_check(%i[networks])
      # return
      d_networks
    end
  end
end
