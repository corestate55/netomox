# frozen_string_literal: true

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

      # rubocop:disable Metrics/MethodLength
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
      # rubocop:enable Metrics/MethodLength

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

      def check_exist_link_tp
        check('link source/target tp ref check') do |messages|
          all_links do |link, _nw|
            src_refs = link.source.refs
            dst_refs = link.destination.refs
            check_tp_ref(messages, 'source', src_refs, link)
            check_tp_ref(messages, 'destination', dst_refs, link)
          end
        end
      end

      def check_exist_reverse_link
        check('reverse (bi-directional) link existence') do |messages|
          all_links do |link, nw|
            next if nw.find_link(link.destination, link.source)

            msg = "reverse link of #{link} is not found."
            messages.push(message(:warn, link.path, msg))
          end
        end
      end

      def check_id_uniqueness
        check('object id uniqueness') do |messages|
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
        check('link reference count of terminal-point') do |messages|
          all_termination_points do |tp, node, nw|
            next if tp.regular_ref_count?

            path = [nw.name, node.name, tp.name].join('__')
            msg = "irregular ref_count:#{tp.ref_count}"
            messages.push(message(:warn, path, msg))
          end
        end
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def check_facing_link
        check('facing link in supported layer') do |messages|
          all_termination_points do |tp, node, nw|
            here_link = find_link_source(nw.name, node.name, tp.name)
            next unless here_link

            destination_tp = destination_tp_from_link(here_link)
            unless destination_tp
              msg = "facing-tp:#{destination_tp} is not found"
              messages.push(message(:warn, tp.path, msg))
              next
            end

            tp.supports.each do |ss_tp|
              found_links = find_links_between(ss_tp, destination_tp.supports)
              next unless found_links.empty?

              msg = "facing link not found source:#{ss_tp}" \
                  " (supported #{tp.path}--#{destination_tp.path})"
              messages.push(message(:warn, tp.path, msg))
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def check_family_support_path
        # check node-tp support path consistency
        # TODO: network-node support path consistency
        check('family support path consistency') do |messages|
          all_termination_points do |tp, node, _nw|
            next if tp.supports.empty? && node.supports.empty?

            if node.supports.empty? && !tp.supports.empty?
              msg = "tp:#{tp.path} has supports " \
                    "but node:#{node.path} does not have supports"
              messages.push(message(:warn, tp.path, msg))
              next
            end
            if !tp.supports.empty? && !node.supports.empty?
              node_support_paths = node.supports.map(&:ref_path)
              tp.supports.each do |tp_support|
                next if node_support_paths.find do |p|
                  tp_support.ref_path.start_with?(p)
                end

                msg = "node:#{node.path} does not support same node with " \
                      "tp:#{tp.path}: #{tp_support.ref_parent_path}"
                messages.push(message(:warn, tp.path, msg))
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

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

      def check_tp_ref(messages, target_str, target_refs, link)
        return if find_tp(*target_refs)

        msg = "link #{target_str} path:#{target_refs.join('__')}" \
              " is not found in link:#{link.path}"
        messages.push(message(:error, link.path, msg))
      end

      def link_name_between(ss_tp, ds_tp)
        "#{ss_tp.ref_link_tp_name},#{ds_tp.ref_link_tp_name}"
      end

      def destination_tp_from_link(link)
        destination_ref = link.destination
        find_tp(destination_ref.network_ref,
                destination_ref.node_ref,
                destination_ref.tp_ref)
      end

      def find_links_between(ss_tp, dest_supports)
        found_links = []
        dest_supports.each do |ds_tp|
          support_nw = ss_tp.ref_network
          link_name = link_name_between(ss_tp, ds_tp)
          link = find_link(support_nw, link_name)
          found_links.push(link) if link
        end
        found_links
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
