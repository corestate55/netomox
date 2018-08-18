require_relative 'const'

module NWTopoDSL
  # network attribute base
  class NetworkAttributeBase
    attr_accessor :name, :flags
    attr_reader :type

    def initialize(name: '', flags: [])
      @name = name
      @flags = flags
      @type = ''
    end

    def topo_data
      {
        'name': @name,
        'flags': @flags
      }
    end

    def empty?
      @name.empty? && @flags.empty?
    end
  end

  # attributes for L3 network
  class L3NWAttribute < NetworkAttributeBase
    def initialize(name: '', flags: [])
      super(name: name, flags: flags)
      @type = "#{NS_L3NW}:l3-topology-attributes".freeze
    end
  end

  # attributes for L2 network
  class L2NWAttribute < NetworkAttributeBase
    def initialize(name: '', flags: [])
      super(name: name, flags: flags)
      @type = "#{NS_L2NW}:l2-network-attributes".freeze
    end
  end
end
