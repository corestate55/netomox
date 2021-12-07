# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/error'
require 'netomox/dsl/base'
require 'netomox/dsl/node_attr_rfc'
require 'netomox/dsl/node_attr_ops'
require 'netomox/dsl/node_attr_mddo'
require 'netomox/dsl/tp'

module Netomox
  module DSL
    # supporting node container
    class SupportNode
      # @param [String] nw_ref Network name
      # @param [String] node_ref Node name
      def initialize(nw_ref, node_ref)
        @nw_ref = nw_ref
        @node_ref = node_ref
      end

      # @return [String]
      def path
        [@nw_ref, @node_ref].join('__')
      end

      # @return [Hash] Convert to data
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
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type
      # @!attribute [rw] tp_prefix
      #   @return [String] Prefix of term-point name in this node
      # @!attribute [rw] tp_number
      #   @return [Integer] Index number of term-points
      # @!attribute [rw] term_points
      #   @return [Array<TermPoint>]
      # @!attribute [rw] supports
      #   @return [Array<SupportNode>]
      attr_accessor :tp_prefix, :tp_number, :term_points, :supports

      # @param [Network] parent Parent object (Network)
      # @param [String] name Node name
      # @param [Proc] block Code block to eval this instance
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

      # Add or access term-point by name
      # @param [String] name Term-point name
      # @param [Proc] block Code block to eval the term-point
      # @return [TermPoint]
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

      # Add supporting node
      # @param [String, Array<String>] nw_ref Network name or Array of elements
      # @param [String] node_ref Node name
      def support(nw_ref, node_ref = nil)
        refs = normalize_support_ref(nw_ref, node_ref)
        snode = find_support(refs)
        if snode
          warn "Ignore: Duplicated support definition:#{snode.path} in #{@path}"
        else
          @supports.push(SupportNode.new(*refs))
        end
      end

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Set attribute
      # @param [Hash] attr Attribute data
      def attribute(attr = nil)
        return @attribute if attr.nil?

        @attribute = if @type.key?(NWTYPE_L2)
                       L2NodeAttribute.new(**attr)
                     elsif @type.key?(NWTYPE_L3)
                       L3NodeAttribute.new(**attr)
                     elsif @type.key?(NWTYPE_OPS)
                       OpsNodeAttribute.new(**attr)
                     elsif @type.key?(NWTYPE_MDDO_L1)
                       MddoL1NodeAttribute.new(**attr)
                     elsif @type.key?(NWTYPE_MDDO_L2)
                       MddoL2NodeAttribute.new(**attr)
                     elsif @type.key?(NWTYPE_MDDO_L3)
                       MddoL3NodeAttribute.new(**attr)
                     else
                       {}
                     end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        data = {
          'node-id' => @name,
          "#{NS_TOPO}:termination-point" => @term_points.map(&:topo_data)
        }
        data['supporting-node'] = @supports.map(&:topo_data) unless @supports.empty?
        data[@attribute.type] = @attribute.topo_data unless @attribute.empty?
        data
      end

      # Find all links that between self and destination
      # @param [Node, TermPoint] dst Destination node or term-point
      def links_between(dst)
        find_opts = normalize_links_between(dst)
        @parent.links_between(**find_opts)
      end

      # Add term-point automatically
      # @return [TermPoint]
      def auto_term_point
        tp_name = "#{@tp_prefix}#{@tp_number}"
        @tp_number += 1
        term_point(tp_name)
      end

      # Find or add unidirectional link from self to dst.
      #   Source term-point is added automatically.
      #   If destination is node (not specified term-point),
      #   added term-point automatically in destination node and connect it.
      # @param [Node, TermPoint] dst Destination node or term-point
      # @return [Link]
      def link_to(dst)
        link_spec = normalize_link_to(dst).map(&:name)
        @parent.link link_spec
      end

      # Add bidirectional link from self to dst.
      #   Source term-point is added automatically.
      #   If destination is node (not specified term-point),
      #   added term-point automatically in destination node and connect it.
      # @param [Node, TermPoint] dst Destination node or term-point
      def bdlink_to(dst)
        link_spec = normalize_link_to(dst).map(&:name)
        @parent.bdlink link_spec
      end

      # Find term-point by name
      # @param [String] name Term-point name
      # @return [TermPoint, nil] Found term-point (nil if not found)
      def find_term_point(name)
        @term_points.find { |tp| tp.name == name }
      end
      alias find_tp find_term_point

      # @param [String, Array<String>] nw_ref Network name or Array of path element
      # @param [String] node_ref Node name
      # @return [SupportNode, nil] Found supporting-node (nil if not found)
      def find_support(nw_ref, node_ref = nil)
        refs = normalize_support_ref(nw_ref, node_ref)
        path = refs.join('__')
        @supports.find { |snode| snode.path == path }
      end

      # sort term-points by name
      # @return [Array<TermPoint>]
      def sort_tp_by_name
        @term_points.sort do |tp_a, tp_b|
          ret = tp_a.name.casecmp(tp_b.name)
          ret.zero? ? tp_a.name <=> tp_b.name : ret
        end
      end

      # sort term-points by name (overwrite itself)
      # @return [Array<TermPoint>]
      def sort_tp_by_name!
        term_points = sort_tp_by_name
        @term_points = term_points
      end

      private

      # @param [Node, TermPoint] dst Destination node or term-point
      # @return [Array<DSLObjectBase>] Search option (array of Node or TermPoint)
      # @raise [DSLInvalidArgumentError]
      # @see Network#normalize_link_args
      def normalize_link_to(dst)
        case dst
        when TermPoint
          [self, auto_term_point, dst.parent, dst]
        when Node
          [self, auto_term_point, dst, dst.auto_term_point]
        else
          raise DSLInvalidArgumentError, "Cannot connect from #{@path} to #{dst}"
        end
      end

      # @param [Node, TermPoint] dst Destination node or term-point
      # @return [Hash] Search options
      # @raise [DSLInvalidArgumentError]
      # @see Network#normalize_find_link_args
      def normalize_links_between(dst)
        case dst
        when TermPoint
          { src_node_name: @name,
            dst_node_name: dst.parent.name, dst_tp_name: dst.name }
        when Node
          { src_node_name: @name, dst_node_name: dst.name }
        else
          raise DSLInvalidArgumentError, "Cannot exec find from #{@path} to #{dst}"
        end
      end

      # Normalize path (elements or array of elements) to array
      # @param [String, Array<String>] nw_ref Network name or Array [nw_ref, node_ref]
      # @param node_ref [String] node_ref (if nw_ref is a String)
      # @return [Array<String>]
      # @raise [DSLInvalidArgumentError]
      def normalize_support_ref(nw_ref, node_ref = nil)
        # with 1 arg (an array)
        return nw_ref if nw_ref.is_a?(Array) && check_normalize_args(nw_ref, 2)

        # with 2 args
        args = [nw_ref, node_ref]
        return args if check_normalize_args(args, 2)

        raise DSLInvalidArgumentError, 'Support node args is not satisfied: ' \
          "nw_ref:#{nw_ref}, node_ref:#{node_ref}"
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
