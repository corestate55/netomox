require_relative 'topo_network'

module TopoChecker
  # Network for topology data (diff functions)
  class Network < TopoObjectBase
    def diff(other)
      # forward check
      d_network = Network.new('network-id' => @name)
      d_network.nodes = diff_forward_check_of(:nodes, other)
      d_network.links = diff_forward_check_of(:links, other)
      d_network.supports = diff_supports(other)
      d_network.attribute = diff_attribute(other)
      d_network.diff_state = @diff_state
      # backward check
      d_network.diff_backward_check(%i[nodes links supports attribute])
      # return
      d_network
    end
  end
end
