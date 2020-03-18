# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/base'
require 'netomox/dsl/node_attr'
require 'netomox/dsl/tp'

module Netomox
  module DSL
    # supporting node container
    class SupportNode
      def initialize(nw_ref, node_ref)
        @nw_ref = nw_ref
        @node_ref = node_ref
      end

      def path
        [@nw_ref, @node_ref].join('__')
      end

      def topo_data
        {
          'network-ref' => @nw_ref,
          'node-ref' => @node_ref
        }
      end
    end

    # rubocop:disable Metrics/ClassLength
    # node, tp container
    class Node < DSLObjectBase
      attr_reader :type
      attr_accessor :tp_prefix, :tp_number, :term_points, :supports

      def initialize(parent, name, &block)
        super(parent, name)
        @term_points = []
        @type = @parent.type
        @supports = [] # supporting node
        @attribute = {} # for augments
        @tp_prefix = 'p'
        @tp_number = 0
        register(&block) if block_given?
      end

      def term_point(name, &block)
        tp = find_term_point(name)
        if tp
          tp.register(&block) if block_given?
        else
          tp = TermPoint.new(self, name, &block)
          @term_points.push(tp)
        end
        tp
      end
      alias tp term_point

      def support(nw_ref, node_ref = false)
        refs = normalize_support_ref(nw_ref, node_ref)
        snode = find_support(refs)
        if snode
          warn "Ignore: Duplicated support definition:#{snode.path} in #{@path}"
        else
          @supports.push(SupportNode.new(*refs))
        end
      end

      def attribute(attr = nil)
        return @attribute if attr.nil?

        @attribute = if @type.key?(NWTYPE_L2)
                       L2NodeAttribute.new(attr)
                     elsif @type.key?(NWTYPE_L3)
                       L3NodeAttribute.new(attr)
                     else
                       {}
                     end
      end

      def topo_data
        data = {
          'node-id' => @name,
          "#{NS_TOPO}:termination-point" => @term_points.map(&:topo_data)
        }
        unless @supports.empty?
          data['supporting-node'] = @supports.map(&:topo_data)
        end
        data[@attribute.type] = @attribute.topo_data unless @attribute.empty?
        data
      end

      def links_between(dst)
        find_opts = normalize_links_between(dst)
        @parent.links_between(find_opts)
      end

      def auto_term_point
        tp_name = "#{@tp_prefix}#{@tp_number}"
        @tp_number += 1
        term_point(tp_name)
      end

      def link_to(dst)
        link_spec = normalize_link_to(dst).map(&:name)
        @parent.link link_spec
      end

      def bdlink_to(dst)
        link_spec = normalize_link_to(dst).map(&:name)
        @parent.bdlink link_spec
      end

      def find_term_point(name)
        @term_points.find { |tp| tp.name == name }
      end
      alias find_tp find_term_point

      def find_support(nw_ref, node_ref = false)
        refs = normalize_support_ref(nw_ref, node_ref)
        path = refs.join('__')
        @supports.find { |snode| snode.path == path }
      end

      def sort_tp_by_name
        @term_points.sort do |tp_a, tp_b|
          ret = tp_a.name.casecmp(tp_b.name)
          ret.zero? ? tp_a.name <=> tp_b.name : ret
        end
      end

      def sort_tp_by_name!
        term_points = sort_tp_by_name
        @term_points = term_points
      end

      private

      def normalize_link_to(dst)
        case dst
        when TermPoint
          [self, auto_term_point, dst.parent, dst]
        when Node
          [self, auto_term_point, dst, dst.auto_term_point]
        else
          warn "Cannot connect from #{@path} to #{dst}"
        end
      end

      def normalize_links_between(dst)
        case dst
        when TermPoint
          { src_node_name: @name,
            dst_node_name: dst.parent.name, dst_tp_name: dst.name }
        when Node
          { src_node_name: @name, dst_node_name: dst.name }
        else
          warn "Cannot exec find from #{@path} to #{dst}"
        end
      end

      def normalize_support_ref(nw_ref, node_ref = false)
        # with 2 args or 1 arg (array)
        node_ref ? [nw_ref, node_ref] : nw_ref
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
