require_relative 'topo_const'
require_relative 'topo_node'
require_relative 'topo_link'
require_relative 'topo_support_network'
require_relative 'topo_network_attr'
require_relative 'topo_object_base'

module TopoChecker
  # Network for topology data
  class Network < TopoObjectBase
    attr_reader :network_types, :nodes, :links

    def initialize(data)
      super(data['network-id'])
      @network_types = data['network-types']
      setup_nodes(data)
      setup_links(data)
      setup_supports(data, 'supporting-network', SupportingNetwork)
      setup_attribute(data,[
        { key: "#{NS_L2NW}:l2-network-attributes", klass: L2NetworkAttribute },
        { key: "#{NS_L3NW}:l3-topology-attributes", klass: L3NetworkAttribute }
      ])
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

    private

    def setup_nodes(data)
      @nodes = []
      @nodes = data['node'].map do |node|
        create_node(node)
      end
    end

    def setup_links(data)
      @links = []
      @links = data["#{NS_TOPO}:link"].map do |link|
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
