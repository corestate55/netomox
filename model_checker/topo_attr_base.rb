module TopoChecker
  # Base class for attribute
  class AttributeBase
    attr_accessor :diff_state

    def initialize(keys, keys_with_default = [])
      @keys = keys
      @keys_with_default = keys_with_default # keys to except empty check
      @diff_state = nil
    end

    def empty?
      (@keys - @keys_with_default).inject(true) do |m, k|
        m && send(k).empty?
      end
    end

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      return false unless self.class.name == other.class.name
      @keys.inject(true) { |m, k| m && send(k) == other.send(k) }
    end

    def to_s
      '## AttributeBase#to_s MUST BE OVER-RIDE ##'
    end
  end
end
