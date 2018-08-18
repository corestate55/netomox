require_relative 'topo_node'
require_relative 'topo_link'
require_relative 'topo_support_network'

module TopoChecker
  # Netwrok for topology data
  class Network
    attr_reader :network_types, :name, :path,
                :nodes, :links, :supporting_networks
    alias_method :supports, :supporting_networks

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

    def -(other)
      nodes_diff(other)
      links_diff(other)
      deleted_snws = @supporting_networks - other.supports
      added_snws = other.supports - @supporting_networks
      kept_snws = @supporting_networks & other.supports
      puts '- supporting networks'
      puts "  - deleted sup-tps: #{deleted_snws.map(&:to_s)}"
      puts "  - added   sup-tps: #{added_snws.map(&:to_s)}"
      puts "  - kept    sup-tps: #{kept_snws.map(&:to_s)}"
    end

    private

    def nodes_diff(other)
      deleted_nodes = @nodes - other.nodes
      added_nodes = other.nodes - @nodes
      kept_nodes = @nodes & other.nodes
      puts '- nodes'
      puts "  - deleted nodes: #{deleted_nodes.map(&:to_s)}"
      puts "  - added   nodes: #{added_nodes.map(&:to_s)}"
      puts "  - kept    nodes: #{kept_nodes.map(&:to_s)}"
      kept_nodes.each do |node|
        lhs_node = @nodes.find { |n| n.eql?(node) }
        rhs_node = other.nodes.find { |n| n.eql?(node) }
        puts "  ## check #{lhs_node}--#{rhs_node} : change or not"
        lhs_node - rhs_node
      end
    end

    def links_diff(other)
      ## TODO it does not works ????
      # deleted_links = @links - other.links
      # added_links = other.links - @links
      # kept_links = @links & other.links

      ## workaround
      lmap = @links.map(&:name)
      rmap = other.links.map(&:name)
      deleted_links = (lmap - rmap).map do |dl|
        @links.find { |l| l.name == dl }
      end
      added_links = (rmap - lmap).map do |al|
        other.links.find { |l| l.name == al }
      end
      kept_links = (lmap & rmap).map do |kl|
        @links.find { |l| l.name == kl }
      end
      puts '- links'
      puts "  - deleted links: #{deleted_links.map(&:to_s)}"
      puts "  - added   links: #{added_links.map(&:to_s)}"
      puts "  - kept    links: #{kept_links.map(&:to_s)}"
      kept_links.each do |link|
        lhs_link = @links.find { |n| n.eql?(link) }
        rhs_link = other.links.find { |n| n.eql?(link) }
        puts "  ## check #{lhs_link}--#{rhs_link} : change or not"
        lhs_link - rhs_link
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
