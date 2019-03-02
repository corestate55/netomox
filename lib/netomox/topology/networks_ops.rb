require 'netomox/topology/networks'

module Netomox
  module Topology
    # Networks for Topology data (operations for multiple networks)
    class Networks < TopoObjectBase
      def check_exist_supporting_network
        result = {
          checkup: 'supporting network existence',
          messages: []
        }
        all_networks do |nw|
          nw.supports.each do |snw|
            next if find_network(snw.network_ref)
            message = {
              severity: :error,
              path: nw.path,
              message: "definition referred as supporting network #{snw} is not found."
            }
            result[:messages].push(message)
          end
        end
        result
      end

      def check_exist_supporting_node
        result = {
          checkup: 'supporting node existence',
          messages: []
        }
        all_nodes do |node, _nw|
          node.supports.each do |snode|
            next if find_node(snode.network_ref, snode.node_ref)
            message = {
              severity: :error,
              path: node.path,
              message: "definition referred as supporting node #{snode} is not found."
            }
            result[:messages].push(message)
          end
        end
        result
      end

      def check_exist_supporting_tps
        result = {
          checkup: 'supporting terminal-points existence',
          messages: []
        }
        all_termination_points do |tp, _node, _nw|
          tp.supports.each do |stp|
            next if find_tp(stp.network_ref, stp.node_ref, stp.tp_ref)
            message = {
              severity: :error,
              path: tp.path,
              message: "definition referred as supporting tp #{stp} is not found"
            }
            result[:messages].push(message)
          end
        end
        result
      end

      def check_exist_supporting_links
        result = {
          checkup: 'supporting link existence',
          messages: []
        }
        all_links do |link, _nw|
          link.supports.each do |slink|
            next if find_link(slink.network_ref, slink.link_ref)
            message = {
              severity: :error,
              path: link.path,
              message: "definition referred as supporting link #{slink} is not found"
            }
            result[:messages].push(message)
          end
        end
        result
      end

      def check_exist_reverse_link
        result = {
          checkup: 'check reverse link (bidirectional) link existence',
          messages: []
        }
        all_networks do |nw|
          res = nw.check_exist_reverse_link
          result[:messages].push(res) unless res.empty?
        end
        result
      end

      def check_id_uniqueness
        {
          checkup: 'check object id uniqueness',
          messages: [
            check_network_id_uniqueness,
            check_node_id_uniqueness,
            check_link_id_uniqueness,
            check_tp_id_uniqueness
          ].flatten
        }
      end

      def check_tp_ref_count
        result = {
          checkup: 'check link reference count of terminal-point',
          messages: []
        }
        all_links do |link, nw|
          ref_count(nw, link.source)
          ref_count(nw, link.destination)
        end
        all_termination_points do |tp, node, nw|
          next if tp.regular_ref_count?
          path = [nw.name, node.name, tp.name].join('/')
          message = {
            severity: :warn,
            path: path,
            message: "irregular ref_count:#{tp.ref_count}"
          }
          result[:messages].push(message)
        end
        result
      end

      private

      def check_network_id_uniqueness
        network_ids = @networks.map(&:name)
        return [] if @networks.size == network_ids.uniq.size
        {
          severity: :error,
          path: '(networks)',
          message: "found duplicate 'network_id': #{duplicated_element network_ids}"
        }
      end

      def check_node_id_uniqueness
        messages = []
        all_networks do |nw|
          node_ids = nw.nodes.map(&:name)
          next if nw.nodes.size == node_ids.uniq.size
          message = {
            severity: :error,
            path: nw.path,
            message: "found duplicate 'node_id': #{duplicated_element node_ids}"
          }
          messages.push(message)
        end
        messages
      end

      def check_link_id_uniqueness
        messages = []
        all_networks do |nw|
          link_ids = nw.links.map(&:name)
          next if nw.links.size == link_ids.uniq.size
          message = {
            severity: :error,
            path: nw.path,
            message: "found duplicate 'link_id': #{duplicated_element link_ids}"
          }
          messages.push(message)
        end
        messages
      end

      def check_tp_id_uniqueness
        messages = []
        all_nodes do |node, _nw|
          tp_ids = node.termination_points.map(&:name)
          next if node.termination_points.size == tp_ids.uniq.size
          message = {
            severity: :error,
            path: node.path,
            message: "found duplicated 'tp_id': #{duplicated_element tp_ids}"
          }
          messages.push(message)
        end
        messages
      end
    end
  end
end
