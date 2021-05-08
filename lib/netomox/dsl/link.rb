# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/base'
require 'netomox/dsl/link_attr'

module Netomox
  module DSL
    # supporting link container
    class SupportLink
      # @param [String] nw_ref Network name
      # @param [String] link_ref Link name
      def initialize(nw_ref, link_ref)
        @nw_ref = nw_ref
        @link_ref = link_ref
      end

      # @return [String]
      def path
        [@nw_ref, @link_ref].join('__')
      end

      # @return [Hash] Convert to data
      def topo_data
        {
          'network-ref' => @nw_ref,
          'link-ref' => @link_ref
        }
      end
    end

    # termination point reference
    class TermPointRef
      # @!attribute [r] node_ref
      #   @return [String] Node name
      # @!attribute [r] tp_ref
      #   @return [String] Term-point name
      attr_reader :node_ref, :tp_ref

      # @param [String] node_ref Node name
      # @param [String] tp_ref Term-point name
      # @param [String] direction Sourde or destination in link ('source' or 'dest')
      def initialize(node_ref, tp_ref, direction)
        @node_ref = node_ref
        @tp_ref = tp_ref
        @direction = direction
      end

      # Convert to data
      # @return [Hash]
      def topo_data
        {
          "#{@direction}-node" => node_ref,
          "#{@direction}-tp" => tp_ref
        }
      end
    end

    # termination point reference for link source
    class SrcTPRef < TermPointRef
      # @param [String] node_ref Node name
      # @param [String] tp_ref Term-point name
      def initialize(node_ref, tp_ref)
        super(node_ref, tp_ref, 'source')
      end
    end

    # termination point reference for link destination
    class DstTPRef < TermPointRef
      # @param [String] node_ref Node name
      # @param [String] tp_ref Term-point name
      def initialize(node_ref, tp_ref)
        super(node_ref, tp_ref, 'dest')
      end
    end

    # link (unidirectional)
    class Link < DSLObjectBase
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type
      # @!attribute [rw] source
      #   @return [SrcTPRef]
      # @!attribute [rw] destination
      #   @return [DstTPRef]
      # @!attribute [rw] supports
      #   @return [Array<SupportLink>]
      attr_accessor :source, :destination, :supports

      # rubocop:disable Metrics/ParameterLists
      # @param [Network] parent Parent object (Network)
      # @param [String] src_node Source node name
      # @param [String] src_tp Source term-point name
      # @param [String] dst_node Destination node name
      # @param [String] dst_tp Destination term-point name
      # @param [Proc] block Code block to eval this instance
      def initialize(parent, src_node, src_tp, dst_node, dst_tp, &block)
        super(parent, [src_node, src_tp, dst_node, dst_tp].join(','))
        @source = SrcTPRef.new(src_node, src_tp)
        @destination = DstTPRef.new(dst_node, dst_tp)
        @type = @parent.type
        @supports = [] # supporting link
        @attribute = {} # for augments
        register(&block) if block_given?
      end
      # rubocop:enable Metrics/ParameterLists

      # Add supporting link
      # @param [String, Array<String>] nw_ref Network name or Array of elements
      # @param [String] link_ref Link name
      def support(nw_ref, link_ref = nil)
        refs = normalize_support_ref(nw_ref, link_ref)
        slink = find_support(refs)
        if slink
          warn "Ignore: Duplicated support definition:#{slink.path} in #{@path}"
        else
          @supports.push(SupportLink.new(*refs))
        end
      end

      # Set attribute
      # @param [Hash] attr Attribute data
      def attribute(attr)
        @attribute = if @type.key?(NWTYPE_L2)
                       L2LinkAttribute.new(**attr)
                     elsif @type.key?(NWTYPE_L3)
                       L3LinkAttribute.new(**attr)
                     elsif @type.key?(NWTYPE_OPS)
                       OpsLinkAttribute.new(**attr)
                     else
                       {}
                     end
      end

      # @param [String, Array<String>] nw_ref Network name of Array of path element
      # @param [String] link_ref Link name
      # @return [SupportLink, nil] Found supporting-link (nil if not found)
      def find_support(nw_ref, link_ref = nil)
        refs = normalize_support_ref(nw_ref, link_ref)
        path = refs.join('__')
        @supports.find { |slink| slink.path == path }
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        data = {
          'link-id' => @name,
          'source' => @source.topo_data,
          'destination' => @destination.topo_data
        }
        data['supporting-link'] = @supports.map(&:topo_data) unless @supports.empty?
        data[@attribute.type] = @attribute.topo_data unless @attribute.empty?
        data
      end

      private

      # Normalize path (elements or array of elements) to array
      # @param [String, Array<String>] nw_ref Network name or Array [nw_ref, node_ref, tp\ref]
      # @param [String] link_ref (if nw_ref is a String)
      # @return [Array<String>]
      def normalize_support_ref(nw_ref, link_ref = nil)
        # with 2 args or 1 arg (array)
        link_ref ? [nw_ref, link_ref] : nw_ref
      end
    end
  end
end
