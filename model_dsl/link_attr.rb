require_relative 'const'

module NWTopoDSL
  # attribute for L3 link
  class L3LinkAttribute
    attr_accessor :name, :flags, :metric1, :metric2
    attr_reader :type

    def initialize(name: '', flags: [], metric1: nil, metric2: nil)
      @name = name
      @flags = flags
      @metric1 = metric1
      @metric2 = metric2
      @type = "#{NS_L3NW}:l3-link-attributes".freeze
    end

    def topo_data
      {
        'name': @name,
        'flag': @flags,
        'metric1': @metric1,
        'metric2': @metric2
      }
    end

    def empty?
      @name.empty? && @flags.empty? && @metric1.nil? && @metric2.nil?
    end
  end

  # attribute for L2 link
  class L2LinkAttribute
    attr_accessor :name, :flags, :rate, :delay, :srlg
    attr_reader :type

    def initialize(name: '', flags: [], rate: nil, delay: nil, srlg: '')
      @name = name
      @flags = flags
      @rate = rate
      @delay = delay
      @srlg = srlg
      @type = "#{NS_L2NW}:l2-link-attributes".freeze
    end

    def topo_data
      {
        'name': @name,
        'flag': @flags,
        'rate': @rate,
        'delay': @delay,
        'srlg': @srlg
      }
    end

    def empty?
      @name.empty? && @flags.empty? && @rate.nil? && @delay.nil? && @srlg.empty?
    end
  end
end
