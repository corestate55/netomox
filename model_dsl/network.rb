require_relative 'const'
require_relative 'base'
require_relative 'network_attr'
require_relative 'node'
require_relative 'link'

module NWTopoDSL
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
  class Network < DSLObjectBase
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

    def attribute(attr)
      @attribute = if @type.key?(NWTYPE_L2)
                     L2NWAttribute.new(attr)
                   elsif @type.key?(NWTYPE_L3)
                     L3NWAttribute.new(attr)
                   else
                     {}
                   end
    end

    def node(name, &block)
      @nodes.push(Node.new(name, @type, &block))
    end

    def bdlink(src_node, src_tp = false,
               dst_node = false, dst_tp = false, &block)
      # make bidirectional link
      args = if src_tp && dst_node && dst_tp
               # with 4 args
               [src_node, src_tp, dst_node, dst_tp]
             else
               # with 1 arg (with array)
               src_node
             end
      @links.push(
        Link.new(args[0], args[1], args[2], args[3], @type, &block),
        Link.new(args[2], args[3], args[0], args[1], @type, &block)
      )
    end

    # rubocop:disable Metrics/MethodLength
    def topo_data
      data = {
        'network-id': @name,
        'network-types': @type,
        'node': @nodes.map(&:topo_data),
        "#{NS_TOPO}:link": @links.map(&:topo_data)
      }
      unless @supports.empty?
        data['supporting-network'] = @supports.map(&:topo_data)
      end
      data[@attribute.type] = @attribute.topo_data unless @attribute.empty?
      data
    end
    # rubocop:enable Metrics/MethodLength
  end
end
