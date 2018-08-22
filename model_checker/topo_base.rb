require_relative 'topo_diff'
require_relative 'topo_attr_base'

module TopoChecker
  # Toloplogy Object Base
  class TopoObjectBase
    attr_reader :name, :path
    attr_accessor :diff_state, :attribute, :supports
    include TopoDiff

    def initialize(name, parent_path = '')
      @name = name
      @parent_path = parent_path
      @path = parent_path.empty? ? @name : [@parent_path, @name].join('/')
      @diff_state = DiffState.new() # empty state
    end

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      @name == other.name
    end

    def empty?
      @name.empty?
    end

    protected

    def setup_attribute(data, key_klass_list)
      # key_klass_list = [{key: 'NAMESPACE:attr_key', klass: class_name}..]
      # NOTICE: WITHOUT network type checking
      @attribute = AttributeBase.new([]) # empty attribute
      key_klass_list.each do |list|
        next unless data.key?(list[:key])
        @attribute = list[:klass].new(data[list[:key]])
      end
    end

    def setup_supports(data, key, klass)
      @supports = []
      return unless data.key?(key)
      @supports = data[key].map do |support|
        klass.new(support)
      end
    end
  end
end
