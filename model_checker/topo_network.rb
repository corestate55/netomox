require_relative 'topo_const'
require_relative 'topo_node'
require_relative 'topo_link'
require_relative 'topo_support_network'
require_relative 'topo_network_attr'
require_relative 'topo_base'

module TopoChecker
  # Network for topology data
  class Network < TopoObjectBase
    attr_accessor :network_types, :nodes, :links

    def initialize(data)
      super(data['network-id'])
      setup_network_types(data)
      setup_nodes(data)
      setup_links(data)
      setup_supports(data, 'supporting-network', SupportingNetwork)
      key_klass_list = [
        { key: "#{NS_L2NW}:l2-network-attributes", klass: L2NetworkAttribute },
        { key: "#{NS_L3NW}:l3-topology-attributes", klass: L3NetworkAttribute }
      ]
      setup_attribute(data, key_klass_list)
    end

    def find_link(source, destination)
      @links.find do |link|
        link.source == source && link.destination == destination
      end
    end

    def check_all_link_pair
      @links.each do |link|
        next if find_link(link.destination, link.source)
        warn "Not Found: reverse link of #{link}"
      end
    end

    def to_s
      "network:#{@name}"
    end

    def to_data
      {
        'network-types' => @network_types,
        'network-id' => @name,
        '_diff_state_' => @diff_state.to_data,
        'node' => @nodes.map(&:to_data),
        'link' => @links.map(&:to_data),
        'supporting-network' => @supports.map(&:to_data),
        'network-attributes' => @attribute.to_data # TODO: attribute key
      }
    end

    private

    def setup_network_types(data)
      @network_types = data['network-types'] || []
    end

    def setup_nodes(data)
      @nodes = []
      return unless data.key?('node')
      @nodes = data['node'].map do |node|
        create_node(node)
      end
    end

    def setup_links(data)
      @links = []
      link_key = "#{NS_TOPO}:link"
      return unless data.key?(link_key)
      @links = data[link_key].map do |link|
        create_link(link)
      end
    end

    def create_node(data)
      Node.new(data, @path)
    end

    def create_link(data)
      Link.new(data, @path)
    end
  end
end
