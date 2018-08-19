require_relative 'topo_const'
require_relative 'topo_node'
require_relative 'topo_link'
require_relative 'topo_support_network'
require_relative 'topo_network_attr'

module TopoChecker
  # Network for topology data
  class Network
    attr_reader :network_types, :name, :path,
                :nodes, :links, :supporting_networks, :attribute
    alias supports supporting_networks

    def initialize(data)
      @network_types = data['network-types']
      @name = data['network-id']
      @path = @name
      setup_nodes(data)
      setup_links(data)
      setup_supporting_networks(data)
      setup_attribute(data)
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

    def eql?(other)
      # for Networks#-()
      @name == other.name
    end

    def to_s
      "network:#{@name}"
    end

    private

    def setup_attribute(data)
      l2nw_attr_key = "#{NS_L2NW}:l2-network-attributes"
      l3nw_attr_key = "#{NS_L3NW}:l3-topology-attributes"
      # NOTICE: WITHOUT network type checking
      @attribute = if data.key?(l2nw_attr_key)
                     L2NetworkAttribute.new(data[l2nw_attr_key])
                   elsif data.key?(l3nw_attr_key)
                     L3NetworkAttribute.new(data[l3nw_attr_key])
                   else
                     {}
                   end
    end

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

    def setup_supporting_networks(data)
      @supporting_networks = []
      return unless data.key?('supporting-network')
      @supporting_networks = data['supporting-network'].map do |nw|
        SupportingNetwork.new(nw)
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
