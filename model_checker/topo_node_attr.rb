require_relative 'topo_attr_base'
require_relative 'topo_diff_forward'

module TopoChecker
  # attribute for L2 node
  class L2NodeAttribute < AttributeBase
    ATTRS = %i[name descr mgmt_addrs sys_mac_addr mgmt_vid flags].freeze
    attr_accessor(*ATTRS)

    # rubocop:disable Metrics/CyclomaticComplexity
    def initialize(data)
      super(ATTRS)
      @name = data['name'] || ''
      @descr = data['description'] || ''
      @mgmt_addrs = data['management-address'] || []
      @sys_mac_addr = data['sys-mac-address'] || ''
      @mgmt_vid = data['management-vid'] || 0
      @flags = data['flag'] || []
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def to_s
      "attribute: #{@name}"
    end
  end

  # L3 prefix for L3 attribute
  class L3Prefix < AttributeBase
    ATTRS = %i[prefix metric flag].freeze
    attr_accessor(*ATTRS)

    def initialize(data)
      super(ATTRS)
      @prefix = data['prefix'] || ''
      @metric = data['metric'] || 10
      @flag = data['flag'] || ''
    end
  end

  # attribute for L3 node
  class L3NodeAttribute < AttributeBase
    ATTRS = %i[name flags router_id prefixes].freeze
    attr_accessor(*ATTRS)
    include TopoDiff
    include SubAttributeOps

    def initialize(data)
      super(ATTRS)
      @name = data['name'] || ''
      @flags = data['flag'] || []
      @router_id = data['router-id'] || ''
      @prefixes =
        data['prefix'] ? data['prefix'].map { |p| L3Prefix.new(p) } : []
    end

    def to_s
      "attribute: #{@name}"
    end

    def diff(other)
      diff_of(:prefixes, other)
    end

    def fill(state_hash)
      fill_of(:prefixes, state_hash)
    end
  end
end
