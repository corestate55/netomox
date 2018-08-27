require_relative 'topo_attr_base'
require_relative 'topo_diff_forward'

module TopoChecker
  # attribute for L2 node
  class L2NodeAttribute < AttributeBase
    ATTR_DEFS = [
      { int: :name, ext: 'name', default: '' },
      { int: :descr, ext: 'description', default: '' },
      { int: :mgmt_addrs, ext: 'management-address', default: [] },
      { int: :sys_mac_addr, ext: 'sys-mac-address', default: '' },
      { int: :mgmt_vid, ext: 'management-vid', default: 0 },
      { int: :flags, ext: 'flag', default: [] }
    ].freeze
    attr_accessor :name, :descr, :mgmt_addrs, :sys_mac_addr, :mgmt_vid, :flags

    def initialize(data, type)
      super(ATTR_DEFS, data, type)
    end

    def to_s
      "attribute: #{@name}"
    end
  end

  # L3 prefix for L3 attribute
  class L3Prefix < AttributeBase
    ATTR_DEFS = [
      { int: :prefix, ext: 'prefix', default: '' },
      { int: :metric, ext: 'metric', default: 0 },
      { int: :flag, ext: 'flag', default: '' }
    ].freeze
    attr_accessor :prefix, :metric, :flag

    def initialize(data, type)
      super(ATTR_DEFS, data, type)
    end
  end

  # attribute for L3 node
  class L3NodeAttribute < AttributeBase
    ATTR_DEFS = [
      { int: :name, ext: 'name', default: '' },
      { int: :flags, ext: 'flag', default: [] },
      { int: :router_id, ext: 'router-id', default: '' },
      { int: :prefixes, ext: 'prefix', default: [] }
    ].freeze
    attr_accessor :name, :flags, :router_id, :prefixes
    include TopoDiff
    include SubAttributeOps

    def initialize(data, type)
      super(ATTR_DEFS, data, type)
      setup_prefixes(data)
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

    private

    def setup_prefixes(data)
      @prefixes = if data.key?('prefix')
                    data['prefix'].map { |p| L3Prefix.new(p, 'prefix') }
                  else
                    []
                  end
    end
  end
end
