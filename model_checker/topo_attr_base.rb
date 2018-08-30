require_relative 'topo_diff_state'
require_relative 'topo_attr_table'

module TopoChecker
  # Base class for attribute
  class AttributeBase
    attr_accessor :diff_state, :path, :type

    def initialize(attr_table, data, type)
      @attr_table = AttributeTable.new(attr_table)
      @keys = @attr_table.int_keys
      @keys_with_empty_check = @attr_table.int_keys_with_empty_check
      @diff_state = DiffState.new # empty state
      @path = 'attribute' # TODO: dummy for #to_data pair
      @type = type
      setup_members(data)
    end

    def empty?
      mark = @type == '_empty_attr_'
      mark || @keys_with_empty_check.inject(true) do |m, k|
        m && send(k).send(@attr_table.check_of(k))
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
      '## AttributeBase#to_s MUST override in sub class ##'
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
      @keys.each do |k|
        attr = select_child_attr(send(k))
        ext_key = @attr_table.ext_of(k)
        data[ext_key] = attr
      end
      data['_diff_state_'] = @diff_state.to_data unless @diff_state.empty?
      data
    end

    private

    def setup_members(data)
      # define member (attribute) of the class
      # according to @attr_table (ATTR_DEFS in sub-classes of AttributeBase)
      @keys.each do |int_key|
        ext_key = @attr_table.ext_of(int_key)
        default = @attr_table.default_of(int_key)
        value = data[ext_key] || default
        send("#{int_key}=", value)
      end
    end
  end

  # Module to mix-in for attribute that has sub-attribute
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
