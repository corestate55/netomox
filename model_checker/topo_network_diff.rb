require_relative 'topo_network'

module TopoChecker
  # Network for topology data (diff functions)
  class Network
    def -(other)
      diff_nodes(other)
      diff_links(other)
      diff_supports(other)
      diff_attribute(other)
    end

    private

    def diff_attribute(other)
      puts '- network attribute'
      result = if @attribute == other.attribute
                 :kept
               elsif @attribute.empty?
                 :added
               elsif other.attribute.empty?
                 :deleted
               else
                 :changed
               end
      puts "  - #{result}: #{@attribute} => #{other.attribute}"
    end

    def diff_supports(other)
      deleted_snws = @supporting_networks - other.supports
      added_snws = other.supports - @supporting_networks
      kept_snws = @supporting_networks & other.supports
      puts '- supporting networks'
      puts "  - deleted sup-tps: #{deleted_snws.map(&:to_s)}"
      puts "  - added   sup-tps: #{added_snws.map(&:to_s)}"
      puts "  - kept    sup-tps: #{kept_snws.map(&:to_s)}"
    end

    def diff_nodes(other)
      deleted_nodes = @nodes - other.nodes
      added_nodes = other.nodes - @nodes
      kept_nodes = @nodes & other.nodes
      puts '- nodes'
      puts "  - deleted nodes: #{deleted_nodes.map(&:to_s)}"
      puts "  - added   nodes: #{added_nodes.map(&:to_s)}"
      puts "  - kept    nodes: #{kept_nodes.map(&:to_s)}"
      diff_kept_nodes(kept_nodes, other)
    end

    # rubocop:disable Lint/Void
    def diff_kept_nodes(kept_nodes, other)
      kept_nodes.each do |node|
        lhs_node = @nodes.find { |n| n.eql?(node) }
        rhs_node = other.nodes.find { |n| n.eql?(node) }
        puts "  ## check #{lhs_node}--#{rhs_node} : change or not"
        lhs_node - rhs_node # TODO: Lint/Void
      end
    end
    # rubocop:enable Lint/Void

    # rubocop:disable Metrics/AbcSize
    def diff_workaround(other)
      lmap = @links.map(&:name)
      rmap = other.links.map(&:name)
      [
        (lmap - rmap).map { |m| @links.find { |l| l.name == m } },
        (rmap - lmap).map { |m| other.links.find { |l| l.name == m } },
        (lmap & rmap).map { |m| @links.find { |l| l.name == m } }
      ]
    end
    # rubocop:enable Metrics/AbcSize

    def diff_links(other)
      ## TODO: it does not works ????
      # deleted_links = @links - other.links
      # added_links = other.links - @links
      # kept_links = @links & other.links

      ## workaround
      (deleted_links, added_links, kept_links) = diff_workaround(other)
      puts '- links'
      puts "  - deleted links: #{deleted_links.map(&:to_s)}"
      puts "  - added   links: #{added_links.map(&:to_s)}"
      puts "  - kept    links: #{kept_links.map(&:to_s)}"
      diff_kept_links(kept_links, other)
    end

    # rubocop:disable Lint/Void
    def diff_kept_links(kept_links, other)
      kept_links.each do |link|
        lhs_link = @links.find { |n| n.eql?(link) }
        rhs_link = other.links.find { |n| n.eql?(link) }
        puts "  ## check #{lhs_link}--#{rhs_link} : change or not"
        lhs_link - rhs_link # TODO: Lint/Void
      end
    end
    # rubocop:enable Lint/Void
  end
end
