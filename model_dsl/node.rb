require_relative 'const'
require_relative 'tp'

module NWTopoDSL
  # supporting node container
  class SupportNode
    def initialize(nw_ref, node_ref)
      @nw_ref = nw_ref
      @node_ref = node_ref
    end

    def topo_data
      {
        'network-ref': @nw_ref,
        'node-ref': @node_ref
      }
    end
  end

  # node, tp container
  class Node
    def initialize(name, &block)
      @name = name
      @term_points = []
      @supports = [] # supporting node
      @attribute = {} # for augments
      register(&block) if block_given?
    end

    def register(&block)
      instance_eval(&block)
    end

    def term_point(name, &block)
      @term_points.push(TermPoint.new(name, &block))
    end

    def support(nw_ref, node_ref)
      @supports.push(SupportNode.new(nw_ref, node_ref))
    end

    def topo_data
      data = {
        'node-id': @name,
        "#{NS_TOPO}:termination-point": @term_points.map(&:topo_data)
      }
      unless @supports.empty?
        data['supporting-node'] = @supports.map(&:topo_data)
      end
      data
    end
  end
end
