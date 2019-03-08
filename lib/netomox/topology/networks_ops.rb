require 'netomox/topology/networks'
require 'netomox/topology/error'

module Netomox
  module Topology
    # Networks for Topology data (operations for multiple networks)
    # rubocop:disable Metrics/ClassLength
    class Networks < TopoObjectBase
      # rubocop:disable Metrics/MethodLength
      def check_exist_supporting_network
        check('supporting network existence') do |messages|
          all_networks do |nw|
            nw.supports.each do |snw|
              begin
                next if find_network(snw.network_ref)
              rescue TopologyElementNotFoundError => e
                messages.push(message(:error, nw.path, e.message))
              end

              msg = 'definition referred as supporting network ' \
                    "#{snw} is not found."
              messages.push(message(:error, nw.path, msg))
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def check_exist_supporting_node
        check('supporting node existence') do |messages|
          all_nodes do |node, _nw|
            node.supports.each do |snode|
              begin
                next if find_node(snode.network_ref, snode.node_ref)
              rescue TopologyElementNotFoundError => e
                messages.push(message(:error, node.path, e.message))
              end

              msg = 'definition referred as supporting node ' \
                    "#{snode} is not found."
              messages.push(message(:error, node.path, msg))
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def check_exist_supporting_tp
        check('supporting terminal-points existence') do |messages|
          all_termination_points do |tp, _node, _nw|
            tp.supports.each do |stp|
              begin
                next if find_tp(stp.network_ref, stp.node_ref, stp.tp_ref)
              rescue TopologyElementNotFoundError => e
                messages.push(message(:error, tp.path, e.message))
              end

              msg = 'definition referred as supporting tp ' \
                    "#{stp} is not found."
              messages.push(message(:error, tp.path, msg))
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      # rubocop:disable Metrics/MethodLength
      def check_exist_supporting_link
        check('supporting link existence') do |messages|
          all_links do |link, _nw|
            link.supports.each do |slink|
              begin
                next if find_link(slink.network_ref, slink.link_ref)
              rescue TopologyElementNotFoundError => e
                messages.push(message(:error, link.path, e.message))
              end

              msg = 'definition referred as supporting link ' \
                    "#{slink} is not found."
              messages.push(message(:error, link.path, msg))
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      def check_exist_reverse_link
        check('check reverse (bi-directional) link existence') do |messages|
          all_links do |link, nw|
            next if nw.find_link(link.destination, link.source)

            msg = "reverse link of #{link} is not found."
            messages.push(message(:warn, link.path, msg))
          end
        end
      end

      def check_id_uniqueness
        check('check object id uniqueness') do |messages|
          list = [
            check_network_id_uniqueness,
            check_node_id_uniqueness,
            check_link_id_uniqueness,
            check_tp_id_uniqueness
          ]
          messages.push(list)
          messages.flatten!
        end
      end

      def check_tp_ref_count
        update_tp_ref_count
        check('check link reference count of terminal-point') do |messages|
          all_termination_points do |tp, node, nw|
            next if tp.regular_ref_count?

            path = [nw.name, node.name, tp.name].join('/')
            msg = "irregular ref_count:#{tp.ref_count}"
            messages.push(message(:warn, path, msg))
          end
        end
      end

      private

      def check(desc)
        result = {
          checkup: desc,
          messages: []
        }
        yield result[:messages]
        result
      end

      def check_uniqueness
        messages = []
        yield messages
        messages
      end

      def message(severity, path, message)
        {
          severity: severity,
          path: path,
          message: message
        }
      end

      def update_tp_ref_count
        all_links do |link, nw|
          ref_count(nw, link.source)
          ref_count(nw, link.destination)
        end
      end

      def check_network_id_uniqueness
        check_uniqueness do |messages|
          network_ids = @networks.map(&:name)
          next if @networks.size == network_ids.uniq.size

          msg = "found duplicate 'network_id': " \
                "#{duplicated_element network_ids}"
          messages.push(message(:error, '(networks)', msg))
        end
      end

      def check_node_id_uniqueness
        check_uniqueness do |messages|
          all_networks do |nw|
            node_ids = nw.nodes.map(&:name)
            next if nw.nodes.size == node_ids.uniq.size

            msg = "found duplicate 'node_id': #{duplicated_element node_ids}"
            messages.push(message(:error, nw.path, msg))
          end
        end
      end

      def check_link_id_uniqueness
        check_uniqueness do |messages|
          all_networks do |nw|
            link_ids = nw.links.map(&:name)
            next if nw.links.size == link_ids.uniq.size

            msg = "found duplicate 'link_id': #{duplicated_element link_ids}"
            messages.push(message(:error, nw.path, msg))
          end
        end
      end

      def check_tp_id_uniqueness
        check_uniqueness do |messages|
          all_nodes do |node, _nw|
            tp_ids = node.termination_points.map(&:name)
            next if node.termination_points.size == tp_ids.uniq.size

            msg = "found duplicate 'tp_id': #{duplicated_element tp_ids}"
            messages.push(message(:error, node.path, msg))
          end
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
