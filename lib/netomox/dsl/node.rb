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

      def topo_data
        {
          'network-ref' => @nw_ref,
          'node-ref' => @node_ref
        }
      end
    end

    # node, tp container
    class Node < DSLObjectBase
      attr_reader :type
      attr_accessor :tp_prefix, :tp_number

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
        if node_ref
          # with 2 args
          @supports.push(SupportNode.new(nw_ref, node_ref))
        else
          # with 1 arg (with array)
          @supports.push(SupportNode.new(*nw_ref))
        end
      end

      def attribute(attr)
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
    end
  end
end
