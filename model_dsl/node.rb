require_relative 'const'
require_relative 'tp'

module NWTopoDSL
  # prefix info for L3 node attribute
  class L3Prefix
    def initialize(prefix: '', metric: 10, flag: [])
      @prefix = prefix
      @metric = metric
      @flag = flag
    end

    def topo_data
      {
        'prefix': @prefix,
        'metric': @metric,
        'flag': @flag
      }
    end
  end

  # attribute for L3 node
  class L3NodeAttribute
    attr_accessor :name, :flags, :router_id, :prefixes
    attr_reader :type
    def initialize(name: '', flags: [], router_id: '', prefixes: [])
      @name = name
      @flags = flags
      @router_id = router_id
      @prefixes = prefixes.map { |p| L3Prefix.new(p) } unless prefixes.empty?
      @type = "#{NS_L3NW}:l3-node-attributes"
    end

    def topo_data
      {
        'name': @name,
        'flag': @flags,
        'router-id': @router_id,
        'prefix': @prefixes.map(&:topo_data)
      }
    end

    def empty?
      @name.empty? && @flags.empty? && @router_id.empty? && @prefixes.empty?
    end
  end

  # attribute for L2 node
  class L2NodeAttribute
    attr_accessor :name, :flags, :descr, :mgmt_addrs, :sys_mac_addr, :mgmt_vid
    attr_reader :type

    # rubocop:disable Metrics/ParameterLists
    def initialize(name: '', flags: [], descr: '',
                   mgmt_addrs: [], sys_mac_addr: '', mgmt_vid: 0)
      @name = name
      @flags = flags
      @descr = descr
      @mgmt_addrs = mgmt_addrs
      @sys_mac_addr = sys_mac_addr
      @mgmt_vid = mgmt_vid
      @type = "#{NS_L2NW}:l2-node-attributes"
    end
    # rubocop:enable Metrics/ParameterLists

    def topo_data
      {
        'name': @name,
        'description': @descr,
        'management-address': @mgmt_addrs,
        'sys-mac-address': @sys_mac_addr,
        'management-vid': @mgmt_vid,
        'flag': @flags
      }
    end

    def empty?
      @name.empty? && flags.empty? && descr.empty? \
      && @mgmt_addrs.empty? && @sys_mac_addr.empty? && @mgmt_vid.empty?
    end
  end

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
    def initialize(name, nw_type, &block)
      @name = name
      @term_points = []
      @type = nw_type
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
        'node-id': @name,
        "#{NS_TOPO}:termination-point": @term_points.map(&:topo_data)
      }
      unless @supports.empty?
        data['supporting-node'] = @supports.map(&:topo_data)
      end
      data[@attribute.type] = @attribute.topo_data unless @attribute.empty?
      data
    end
  end
end
