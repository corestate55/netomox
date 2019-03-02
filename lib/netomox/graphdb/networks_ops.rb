require 'neography'
require 'netomox/graphdb/networks'

module Netomox
  module GraphDB
    # Networks for graph data (neo4j operation)
    class Networks < Topology::Networks
      def exec_create_objects
        @n4j_node_table = {}
        exec_create_nodes
        exec_create_relations
      end

      def exec_clear_all_objects
        @n4j.execute_query('MATCH (n) DETACH DELETE n')
      end

      private

      def config_neo4j
        @n4j = Neography::Rest.new(@db_info)
      end

      def add_label(object, labels)
        return if labels.nil? || labels.empty?

        labels.each do |label|
          @n4j.add_label(object, label)
        end
      end

      def exec_create_nodes
        node_objects.each do |node|
          n4j_node = @n4j.create_node(node[:property])
          @n4j_node_table[node[:property][:path]] = n4j_node
          add_label(n4j_node, node[:labels])
        end
      end

      def exec_create_relations
        relationship_objects.each do |rel|
          src = @n4j_node_table[rel[:property][:source]]
          dst = @n4j_node_table[rel[:property][:destination]]
          rel = @n4j.create_relationship(rel[:rel_type], src, dst)
          add_label(rel, rel[:labels])
        end
      end
    end
  end
end
