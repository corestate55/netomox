module ModelDSL
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
        "#{@direction}-node": node_ref,
        "#{@direction}-tp": tp_ref
      }
    end
  end

  class SrcTPRef < TermPointRef
    def initialize(node_ref, tp_ref)
      super(node_ref, tp_ref, 'source')
    end
  end

  class DstTPRef < TermPointRef
    def initialize(node_ref, tp_ref)
      super(node_ref, tp_ref, 'destination')
    end
  end

# link (unidirectional)
  class Link
    def initialize(src_node, src_tp, dst_node, dst_tp, &block)
      @name = [src_node, src_tp, dst_node, dst_tp].join(',')
      @source = SrcTPRef.new(src_node, src_tp)
      @destination = DstTPRef.new(dst_node, dst_tp)
      @supports = [] # supporting link
      @attribute = {} # for augments
      register(&block) if block_given?
    end

    def register(&block)
      p '# Link#register'
      instance_eval(&block)
    end

    def topo_data
      {
        'link-id': @name,
        'source': @source.topo_data,
        'destination': @destination.topo_data
      }
    end
  end
end
