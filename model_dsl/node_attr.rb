require_relative 'const'

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
      @prefixes = prefixes.empty? ? [] : prefixes.map { |p| L3Prefix.new(p) }
      @type = "#{NS_L3NW}:l3-node-attributes".freeze
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
      @type = "#{NS_L2NW}:l2-node-attributes".freeze
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
      @name.empty? && @flags.empty? && @descr.empty? \
      && @mgmt_addrs.empty? && @sys_mac_addr.empty? && @mgmt_vid.empty?
    end
  end
end
