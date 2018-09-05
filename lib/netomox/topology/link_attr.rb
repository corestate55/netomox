require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # attribute for L2 link
    class L2LinkAttribute < AttributeBase
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :flags, ext: 'flag', default: [] },
        { int: :rate, ext: 'rate', default: 0 },
        { int: :delay, ext: 'delay', default: 0 },
        { int: :srlg, ext: 'srlg', default: '' }
      ].freeze
      attr_accessor :name, :flags, :rate, :delay, :srlg

      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      def to_s
        "attribute: #{@name}"
      end
    end

    # attribute for L3 link
    class L3LinkAttribute < AttributeBase
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :flags, ext: 'flag', default: [] },
        { int: :metric1, ext: 'metric1', default: 0 },
        { int: :metric2, ext: 'metric2', default: 0 }
      ].freeze
      attr_accessor :name, :flags, :metric1, :metric2

      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      def to_s
        "attribute: #{@name}"
      end
    end
  end
end
