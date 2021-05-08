# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/base'
require 'netomox/dsl/tp_attr'

module Netomox
  module DSL
    # supporting termination point container
    class SupportTermPoint
      # @param [String] nw_ref Network name
      # @param [String] node_ref Node name
      # @param [String] tp_ref Term-point name
      def initialize(nw_ref, node_ref, tp_ref)
        @nw_ref = nw_ref
        @node_ref = node_ref
        @tp_ref = tp_ref
      end

      # @return [String]
      def path
        [@nw_ref, @node_ref, @tp_ref].join('__')
      end

      # Convert to data
      # @return [Hash]
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
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type
      # @!attribute [rw] supports
      #   @return [Array<SupportTermPoint>]
      attr_accessor :supports

      # @param [Node] parent Parent object (Node)
      # @param [String] name Term-point name
      # @param [Block] block Conde block to eval in this instance
      def initialize(parent, name, &block)
        super(parent, name)
        @supports = [] # supporting termination point
        @type = @parent.type
        @attribute = {} # for augments
        register(&block) if block_given?
      end

      # Add supporting term-point
      # @param [String] nw_ref Network name
      # @param [String] node_ref Node name
      # @param [String] tp_ref Term-point name
      def support(nw_ref, node_ref = nil, tp_ref = nil)
        refs = normalize_support_ref(nw_ref, node_ref, tp_ref)
        stp = find_support(refs)
        if stp
          warn "Ignore: Duplicated support definition:#{stp.path} in #{@path}"
        else
          @supports.push(SupportTermPoint.new(*refs))
        end
      end

      # Set attribute
      # @param [Hash] attr Attribute data
      def attribute(attr)
        @attribute = if @type.key?(NWTYPE_L2)
                       L2TPAttribute.new(**attr)
                     elsif @type.key?(NWTYPE_L3)
                       L3TPAttribute.new(**attr)
                     elsif @type.key?(NWTYPE_OPS)
                       OpsTPAttribute.new(**attr)
                     else
                       {}
                     end
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        data = { 'tp-id' => @name }
        data['supporting-termination-point'] = @supports.map(&:topo_data) unless @supports.empty?
        data[@attribute.type] = @attribute.topo_data unless @attribute.empty?
        data
      end

      # Find all links that between source this and destination
      # @param [Node, TermPoint] dst Destination node or term-point
      # @return [Array<Link>]
      def links_between(dst)
        find_opts = normalize_links_between(dst)
        @parent.parent.links_between(**find_opts)
      end

      # Find or add (unidirectional) link from self to dst
      # @param [TermPoint] dst Destination term-point
      # @return [Link]
      def link_to(dst)
        link_spec = normalize_link_to(dst).map(&:name)
        @parent.parent.link link_spec
      end

      # Find or add (bidirectional) links between self and dst
      # @param [TermPoint] dst Destination term-point
      # @return [Link]
      def bdlink_to(dst)
        link_spec = normalize_link_to(dst).map(&:name)
        @parent.parent.bdlink link_spec
      end

      # @param [String, Array<String>] nw_ref Network name or Array of path element
      # @param [String] node_ref Node name
      # @param [tp_ref] tp_ref
      # @return [SupportTermPoint, nil] Found term-point (nil if not found)
      def find_support(nw_ref, node_ref = nil, tp_ref = nil)
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

      # @param [Node, TermPoint] dst Destination node or term-point
      # @return [Hash] search option
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

      # Normalize path (elements or array of elements) to array
      # @param [String, Array<String>] nw_ref Network name or Array [nw_ref, node_ref, tp\ref]
      # @param node_ref [String] node_ref (if nw_ref is a String)
      # @param tp_ref [String] tp_ref (if nw_ref is a String)
      # @return [Array<String>]
      def normalize_support_ref(nw_ref, node_ref = nil, tp_ref = nil)
        # with 3 args or 1 arg (array)
        node_ref && tp_ref ? [nw_ref, node_ref, tp_ref] : nw_ref
      end
    end
  end
end
