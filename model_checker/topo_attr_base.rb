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

    def diff?
      # attribute class has #diff method or not?
      # when attribute has sub-attribute, define #diff method in sub class.
      self.class.instance_methods.include?(:diff)
    end

    def fill?
      self.class.instance_methods.include?(:fill)
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

  # for attribute that has sub-attribute
  module SubAttributeOps
    def diff_of(attr, other)
      return diff_with_empty_attr unless other.diff?
      if empty_added?(send(attr), other.send(attr))
        other.fill(forward: :added)
      elsif empty_deleted?(send(attr), other.send(attr))
        fill(forward: :deleted)
      else
        d_vid_names = diff_list(attr, other) # NOTICE: with TopoDiff mix-in
        other.send("#{attr}=", d_vid_names)
      end
      other
    end

    def fill_of(attr, state_hash)
      send(attr).each do |vid_name|
        set_diff_state(vid_name, state_hash)
      end
    end

    private

    def empty_added?(lhs, rhs)
      lhs.empty? && !rhs.empty?
    end

    def empty_deleted?(lhs, rhs)
      !lhs.empty? && rhs.empty?
    end

    def diff_with_empty_attr
      # when other = AttributeBase (EMPTY Attribute)
      state = { forward: :deleted }
      fill(state)
      @diff_state = DiffState.new(state)
      self
    end
  end
end
