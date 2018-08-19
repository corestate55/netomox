require_relative 'topo_attr_base'

module TopoChecker
  # attribute for L2 link
  class L2LinkAttribute < AttributeBase
    ATTRS = %i[name flags rate delay srlg].freeze
    attr_accessor(*ATTRS)

    def initialize(data)
      super(ATTRS, %i[rate delay])
      @name = data['name'] || ''
      @flags = data['flag'] || []
      @rate = data['rate'] || 0
      @delay = data['delay'] || 1
      @srlg = data['srlg'] || ''
    end

    def to_s
      "attribute: #{@name}"
    end
  end

  # attribute for L3 link
  class L3LinkAttribute < AttributeBase
    ATTRS = %i[name flags metric1 metric2].freeze
    attr_accessor(*ATTRS)

    def initialize(data)
      super(ATTRS, %i[metric1 metric2])
      @name = data['name'] || ''
      @flags = data['flag'] || []
      @metric1 = data['metric1'] || 0
      @metric2 = data['metric2'] || 0
    end

    def to_s
      "attribute: #{@name}"
    end
  end
end
