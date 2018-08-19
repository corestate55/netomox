require_relative 'topo_networks_ops'

module TopoChecker
  # Networks for Topology data (diff function)
  class Networks
    def -(other)
      deleted_networks = @networks - other.networks
      added_networks = other.networks - @networks
      kept_networks = @networks & other.networks
      puts "deleted nws: #{deleted_networks.map(&:to_s)}"
      puts "added   nws: #{added_networks.map(&:to_s)}"
      puts "kept    nws: #{kept_networks.map(&:to_s)}"
      diff_kept_networks(kept_networks, other)
    end

    private

    # rubocop:disable Lint/Void
    def diff_kept_networks(kept_networks, other)
      kept_networks.each do |nw|
        lhs_nw = @networks.find { |n| n.eql?(nw) }
        rhs_nw = other.networks.find { |n| n.eql?(nw) }
        puts "## check #{lhs_nw}--#{rhs_nw} : changed or not"
        lhs_nw - rhs_nw # TODO: Lint/Void
      end
    end
    # rubocop:enable Lint/Void
  end
end
