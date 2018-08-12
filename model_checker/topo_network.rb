require_relative 'topo_node'
require_relative 'topo_link'

module TopoChecker
  # Netwrok for topology data
  class Network
    attr_reader :network_types, :name, :path,
                :nodes, :links, :supporting_networks

    # Supporting network for network topology data
    class SupportingNetwork
      attr_reader :network_ref

      def initialize(data)
        @network_ref = data['network-ref']
      end

      def to_s
        "nw_ref:#{@network_ref}"
      end

      def ref_path
        @network_ref
      end
    end

    def initialize(data)
      @network_types = data['network-types']
      @name = data['network-id']
      @path = @name
      setup_nodes(data)
      setup_links(data)
      setup_supporting_networks(data)
    end

    def find_link(source, destination)
      @links.find do |link|
        link.source == source && link.destination == destination
      end
    end

    def check_all_link_pair
      @links.each do |link|
        # p "#{link.to_s}"
        next if find_link(link.destination, link.source)
        warn "Not Found: reverse link of #{link}"
      end
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
      @links = data['ietf-network-topology:link'].map do |link|
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
