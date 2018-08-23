require_relative 'topo_networks_ops'

module TopoChecker
  # Networks for Topology data (diff function)
  class Networks < TopoObjectBase
    def diff(other)
      d_nws = Networks.new({})

      # forward check
      nws_diff = diff_list(:networks, other)
      d_nws.networks = nws_diff.map do |nd|
        if nd.diff_state.forward == :kept
          nd.diff(nd.diff_state.pair)
        else
          nd
        end
      end

      # backward check
      diff_states = d_nws.networks.map { |d| d.diff_state.forward }
      if diff_states.all?(:kept)
        d_nws.diff_state = DiffState.new(backward: :kept)
      else
        d_nws.diff_state = DiffState.new(backward: :changed)
      end

      # return
      d_nws
    end
  end
end
