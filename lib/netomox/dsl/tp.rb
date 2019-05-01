require 'netomox/const'
require 'netomox/dsl/base'
require 'netomox/dsl/tp_attr'

module Netomox
  module DSL
    # supporting termination point container
    class SupportTermPoint
      def initialize(nw_ref, node_ref, tp_ref)
        @nw_ref = nw_ref
        @node_ref = node_ref
        @tp_ref = tp_ref
      end

      def path
        [@nw_ref, @node_ref, @tp_ref].join('__')
      end

      def topo_data
        {
          'network-ref' => @nw_ref,
          'node-ref' => @node_ref,
          'tp-ref' => @tp_ref
        }
      end
    end

    # termination point
    class TermPoint < DSLObjectBase
      attr_accessor :type

      def initialize(parent, name, &block)
        super(parent, name)
        @supports = [] # supporting termination point
        @type = @parent.type
        @attribute = {} # for augments
        register(&block) if block_given?
      end

      def support(nw_ref, node_ref = false, tp_ref = false)
        refs = normalize_support_ref(nw_ref, node_ref, tp_ref)
        stp = find_support(refs)
        warn "Duplicated support definition:#{stp.path} in #{@path}" if stp
        @supports.push(SupportTermPoint.new(*refs))
      end

      def attribute(attr)
        @attribute = if @type.key?(NWTYPE_L2)
                       L2TPAttribute.new(attr)
                     elsif @type.key?(NWTYPE_L3)
                       L3TPAttribute.new(attr)
                     else
                       {}
                     end
      end

      def topo_data
        data = { 'tp-id' => @name }
        unless @supports.empty?
          data['supporting-termination-point'] = @supports.map(&:topo_data)
        end
        data[@attribute.type] = @attribute.topo_data unless @attribute.empty?
        data
      end

      def links_between(dst)
        find_opts = normalize_links_between(dst)
        @parent.parent.links_between(find_opts)
      end

      def link_to(dst)
        link_spec = normalize_link_to(dst).map(&:name)
        @parent.parent.link link_spec
      end

      def bdlink_to(dst)
        link_spec = normalize_link_to(dst).map(&:name)
        @parent.parent.bdlink link_spec
      end

      def find_support(nw_ref, node_ref = false, tp_ref = false)
        refs = normalize_support_ref(nw_ref, node_ref, tp_ref)
        path = refs.join('__')
        @supports.find { |stp| stp.path == path }
      end

      private

      def normalize_link_to(dst)
        case dst
        when TermPoint
          [@parent, self, dst.parent, dst]
        when Node
          [@parent, self, dst, dst.auto_term_point]
        end
      end

      def normalize_links_between(dst)
        case dst
        when TermPoint
          { src_node_name: @parent.name, src_tp_name: @name,
            dst_node_name: dst.parent.name, dst_tp_name: dst.name }
        when Node
          { src_node_name: @parent.name, src_tp_name: @name,
            dst_node_name: dst.name }
        else
          warn "Cannot exec find from #{@path} to #{dst}"
        end
      end

      def normalize_support_ref(nw_ref, node_ref = false, tp_ref = false)
        # with 3 args or 1 arg (array)
        node_ref && tp_ref ? [nw_ref, node_ref, tp_ref] : nw_ref
      end
    end
  end
end
