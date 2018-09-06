require 'netomox/topology/networks'

module Netomox
  module Topology
    # Networks for Topology data (operations for multiple networks)
    class Networks < TopoObjectBase
      def check_all_supporting_networks
        all_networks do |nw|
          nw.supports.each do |snw|
            next if find_network(snw.network_ref)
            warn "Not found: #{snw} of nw:#{nw.name}"
          end
        end
      end

      def check_all_supporting_nodes
        all_nodes do |node, nw|
          node.supports.each do |snode|
            # p "#{nw.network_id}/#{node.node_id} refs #{snode}"
            next if find_node(snode.network_ref, snode.node_ref)
            warn "Not Found: #{snode} of node:#{nw.name}/#{node.name}"
          end
        end
      end

      def check_all_supporting_tps
        all_termination_points do |tp, node, nw|
          tp.supports.each do |stp|
            # p "#{nw.network_id}/#{node.node_id}/#{tp.tp_id} refs #{stp}"
            next if find_tp(stp.network_ref, stp.node_ref, stp.tp_ref)
            warn "Not Found: #{stp} of tp:#{nw.name}/#{node.name}/#{tp.name}"
          end
        end
      end

      def check_all_supporting_links
        all_links do |link, nw|
          link.supports.each do |slink|
            # p "#{nw.network_id}/#{link.link_id} refs #{slink}"
            next if find_link(slink.network_ref, slink.link_ref)
            warn "Not Found: #{slink} of link:#{nw.name}/#{link.name}"
          end
        end
      end

      def check_all_link_pair
        all_networks(&:check_all_link_pair)
      end

      def check_object_uniqueness
        check_network_id_uniqueness
        check_node_id_uniqueness
        check_link_id_uniqueness
        check_tp_id_uniqueness
      end

      def check_tp_ref_count
        all_links do |link, nw|
          ref_count(nw, link.source)
          ref_count(nw, link.destination)
        end

        all_termination_points do |tp, node, nw|
          if tp.irregular_ref_count?
            path = [nw.name, node.name, tp.name].join('/')
            warn "WARNING: #{path} ref_count = #{tp.ref_count}"
          end
        end
      end

      private

      def check_network_id_uniqueness
        network_ids = @networks.map(&:name)
        return if @networks.size == network_ids.uniq.size
        warn "WARNING: There are duplicate 'network_id's"
        warn "#=> #{ununique_element network_ids}"
      end

      def check_node_id_uniqueness
        all_networks do |nw|
          node_ids = nw.nodes.map(&:name)
          next if nw.nodes.size == node_ids.uniq.size
          warn "WARNING: There are duplicate 'node_id's in #{nw.name}"
          warn "#=> #{ununique_element node_ids}"
        end
      end

      def check_link_id_uniqueness
        all_networks do |nw|
          link_ids = nw.links.map(&:name)
          next if nw.links.size == link_ids.uniq.size
          warn "WARNING: There are duplicate 'link_id's in #{nw.name}"
          warn "#=> #{ununique_element link_ids}"
        end
      end

      def check_tp_id_uniqueness
        all_nodes do |node, nw|
          tp_ids = node.termination_points.map(&:name)
          next if node.termination_points.size == tp_ids.uniq.size
          path = "#{nw.name}/#{node.name}"
          warn "WARNING: There are duplicate 'tp_id's in #{path}"
          warn "#=> #{ununique_element tp_ids}"
        end
      end
    end
  end
end
