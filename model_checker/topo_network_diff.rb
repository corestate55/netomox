require_relative 'topo_network'

module TopoChecker
  # Network for topology data (diff functions)
  class Network < TopoObjectBase
    def diff(other)
      d_network = Network.new({ 'network-id' => @name })
      nodes_diff = diff_list(:nodes, other)
      d_network.nodes = nodes_diff.map do |nd|
        if nd.diff_state.forward == :kept
          nd.diff(nd.diff_state.pair)
        else
          nd
        end
      end
      links_diff = diff_list(:links, other)
      d_network.links = links_diff.map do |ld|
        if ld.diff_state.forward == :kept
          ld.diff(ld.diff_state.pair)
        else
          ld
        end
      end
      d_network.supports = diff_supports(other)
      d_network.attribute = diff_attribute(other)
      p "### check [#{@diff_state}], [#{other.diff_state}]"
      d_network.diff_state = @diff_state
      d_network
    end
  end
end