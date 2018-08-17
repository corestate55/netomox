require_relative 'dsl_const'
require_relative 'dsl_node'
require_relative 'dsl_link'

module ModelDSL
  # supporting network container
  class SupportNetwork
    def initialize(nw_ref)
      @nw_ref = nw_ref
    end

    def topo_data
      { 'network-ref': @nw_ref }
    end
  end

  # network, node and link container
  class Network
    def initialize(name, &block)
      @name = name
      @type = {}
      @nodes = []
      @links = []
      @supports = [] # supporting network
      @attribute = {} # for augments
      register(&block) if block_given?
    end

    def type(type)
      @type[type] = {} ## TODO recursive type definition
    end

    def support(nw_ref)
      @supports.push(SupportNetwork.new(nw_ref))
    end

    def register(&block)
      instance_eval(&block)
    end

    def node(name, &block)
      @nodes.push(Node.new(name, &block))
    end

    def bdlink(src_node, src_tp, dst_node, dst_tp, &block)
      # make bidirectional link
      @links.push(
        Link.new(src_node, src_tp, dst_node, dst_tp, &block),
        Link.new(dst_node, dst_tp, src_node, src_tp, &block)
      )
    end

    def topo_data
      data = {
        'network-id': @name,
        'network-types': @type,
        'node': @nodes.map(&:topo_data),
        "#{NS_TOPO}:link": @links.map(&:topo_data)
      }
      data['supporting-network'] = @supports.map(&:topo_data) unless @supports.empty?
      data
    end
  end
end
