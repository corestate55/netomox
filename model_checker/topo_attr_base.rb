require_relative 'topo_diff_state'

module TopoChecker
  # Base class for attribute
  class AttributeBase
    attr_accessor :diff_state, :path

    def initialize(keys, keys_with_default = [])
      @keys = keys
      @keys_with_default = keys_with_default # keys to except empty check
      @diff_state = DiffState.new # empty state
      @path = 'attribute' # TODO: dummy for #to_data
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

    def select_child_attr(attr)
      if attr.is_a?(Array) && attr.all? { |d| d.is_a?(AttributeBase) }
        attr.map(&:to_data)
      else
        attr
      end
    end

    def to_data
      data = {}
      @keys.each do |k| # TODO: key mapping
        attr = select_child_attr(send(k))
        data[k] = attr
      end
      data['_diff_state_'] = @diff_state.to_data unless @diff_state.empty?
      data
    end
  end
end
