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
      def initialize(name, nw_type, &block)
        @name = name
        @term_points = []
        @type = nw_type
        @supports = [] # supporting node
        @attribute = {} # for augments
        register(&block) if block_given?
      end

      def term_point(name, &block)
        @term_points.push(TermPoint.new(name, @type, &block))
      end

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
    end
  end
end
