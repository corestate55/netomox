require 'netomox/const'
require 'netomox/dsl/base'
require 'netomox/dsl/link_attr'

module Netomox
  module DSL
    # supporting link container
    class SupportLink
      def initialize(nw_ref, link_ref)
        @nw_ref = nw_ref
        @link_ref = link_ref
      end

      def topo_data
        {
          'network-ref' => @nw_ref,
          'link-ref' => @link_ref
        }
      end
    end

    # termination point reference
    class TermPointRef
      attr_reader :node_ref, :tp_ref
      def initialize(node_ref, tp_ref, direction)
        @node_ref = node_ref
        @tp_ref = tp_ref
        @direction = direction
      end

      def topo_data
        {
          "#{@direction}-node" => node_ref,
          "#{@direction}-tp" => tp_ref
        }
      end
    end

    # termination point reference for link source
    class SrcTPRef < TermPointRef
      def initialize(node_ref, tp_ref)
        super(node_ref, tp_ref, 'source')
      end
    end

    # termination point reference for link destination
    class DstTPRef < TermPointRef
      def initialize(node_ref, tp_ref)
        super(node_ref, tp_ref, 'dest')
      end
    end

    # link (unidirectional)
    class Link < DSLObjectBase
      attr_reader :type, :source, :destination

      # rubocop:disable Metrics/ParameterLists
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

      def support(nw_ref, link_ref = false)
        if link_ref
          # with 2 args
          @supports.push(SupportLink.new(nw_ref, link_ref))
        else
          # with 1 arg (with array)
          @supports.push(SupportLink.new(*nw_ref))
        end
      end

      def attribute(attr)
        @attribute = if @type.key?(NWTYPE_L2)
                       L2LinkAttribute.new(attr)
                     elsif @type.key?(NWTYPE_L3)
                       L3LinkAttribute.new(attr)
                     else
                       {}
                     end
      end

      def topo_data
        data = {
          'link-id' => @name,
          'source' => @source.topo_data,
          'destination' => @destination.topo_data
        }
        unless @supports.empty?
          data['supporting-link'] = @supports.map(&:topo_data)
        end
        data[@attribute.type] = @attribute.topo_data unless @attribute.empty?
        data
      end
    end
  end
end
