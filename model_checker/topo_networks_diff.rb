require_relative 'topo_networks_ops'
require_relative 'topo_diff'

module TopoChecker
  # Networks for Topology data (diff function)
  class Networks
    include TopoDiff

    def -(other)
      diff_networks(other)
    end

    private

    def diff_networks(other)
      diff_table = diff_list(:networks, other)
      print_diff_list(:networks, diff_table)
      diff_kept(:networks, diff_table, other)
    end
  end
end
