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
        if node_ref && tp_ref
          # with 3 args
          @supports.push(SupportTermPoint.new(nw_ref, node_ref, tp_ref))
        else
          # with 1 arg (with array)
          @supports.push(SupportTermPoint.new(*nw_ref))
        end
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
    end
  end
end
