require_relative 'topo_network'
require_relative 'topo_diff'

module TopoChecker
  # Network for topology data (diff functions)
  class Network
    include TopoDiff

    def -(other)
      diff_nodes(other)
      diff_links(other)
      diff_supports(other)
      diff_attribute(other)
    end

    private

    def diff_nodes(other)
      diff_table = diff_list(:nodes, other)
      print_diff_list(:nodes, diff_table)
      diff_kept(:nodes, diff_table, other)
    end

    # diff workaround
    def dw_deleted(lmap, rmap)
      (lmap - rmap).map { |m| @links.find { |l| l.name == m } }
    end

    # diff workaround
    def dw_added(lmap, rmap, other)
      (rmap - lmap).map { |m| other.links.find { |l| l.name == m } }
    end

    # diff workaround
    def dw_kept(lmap, rmap)
      (lmap & rmap).map { |m| @links.find { |l| l.name == m } }
    end

    def diff_workaround(other)
      lmap = @links.map(&:name)
      rmap = other.links.map(&:name)
      {
        deleted: dw_deleted(lmap, rmap),
        added: dw_added(lmap, rmap, other),
        kept: dw_kept(lmap, rmap)
      }
    end

    def diff_links(other)
      ## TODO: it does not works ????
      # diff_table = diff_list(:links, other)

      ## workaround
      diff_table = diff_workaround(other)
      print_diff_list(:links, diff_table)
      diff_kept(:links, diff_table, other)
    end
  end
end
