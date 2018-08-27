require_relative 'topo_attr_base'

module TopoChecker
  # base class for network topology
  class NetworkAttributeBase < AttributeBase
    ATTR_DEFS = [
      { int: :name, ext: 'name', default: '' },
      { int: :flags, ext: 'flag', default: [] }
    ].freeze
    attr_accessor :name, :flags

    def initialize(data, type)
      super(ATTR_DEFS, data, type)
    end

    def to_s
      "attribute:#{@name},#{@flags}"
    end
  end

  # attribute for L2 network
  class L2NetworkAttribute < NetworkAttributeBase; end
  # attribute for L3 network
  class L3NetworkAttribute < NetworkAttributeBase; end
end
