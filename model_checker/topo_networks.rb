require_relative 'topo_const'
require_relative 'topo_network'
require_relative 'topo_base'

module TopoChecker
  # Networks for Topology data
  class Networks < TopoObjectBase
    attr_accessor :networks
    include TopoDiff

    def initialize(data)
      super('networks')
      setup_networks(data)
    end

    def find_network(network_ref)
      @networks.find { |nw| nw.name == network_ref }
    end

    def find_node(network_ref, node_ref)
      find_network(network_ref).nodes.find do |node|
        node.name == node_ref
      end
    end

    def find_tp(network_ref, node_ref, tp_ref)
      find_node(network_ref, node_ref).termination_points.find do |tp|
        tp.name == tp_ref
      end
    end

    def find_link(network_ref, link_ref)
      find_network(network_ref).links.find do |link|
        link.name == link_ref
      end
    end

    def all_networks
      @networks.each do |nw|
        yield nw
      end
    end

    def all_nodes
      all_networks do |nw|
        nw.nodes.each do |node|
          yield node, nw
        end
      end
    end

    def all_links
      all_networks do |nw|
        nw.links.each do |link|
          yield link, nw
        end
      end
    end

    def all_termination_points
      all_nodes do |node, nw|
        node.termination_points.each do |tp|
          yield tp, node, nw
        end
      end
    end

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

    def fill_diff_state
      fill_diff_state_of(%i[networks])
    end

    def to_data
      {
        "#{NS_NW}:networks" => {
          '_diff_state_' => @diff_state.to_data,
          'network' => @networks.map(&:to_data)
        }
      }
    end

    private

    def setup_networks(data)
      @networks = []
      nws_key = "#{NS_NW}:networks"
      return unless data.key?(nws_key)
      data[nws_key]['network'].each do |each|
        @networks.push create_network(each)
      end
    end

    def create_network(data)
      Network.new(data)
    end

    def ununique_element(list)
      list.group_by { |i| i }.reject { |_k, v| v.one? }.keys
    end

    def ref_count(network, tp_ref)
      tp = find_tp(network.name, tp_ref.node_ref, tp_ref.tp_ref)
      tp.ref_count_up if tp
    end
  end
end
