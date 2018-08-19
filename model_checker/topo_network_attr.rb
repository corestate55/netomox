require_relative 'topo_attr_base'

module TopoChecker
  # base class for network topology
  class NetworkAttributeBase < AttributeBase
    ATTRS = %i[name flags].freeze
    attr_accessor(*ATTRS)

    def initialize(data)
      super(ATTRS)
      @name = data['name'] || ''
      @flags = data['flag'] || []
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
