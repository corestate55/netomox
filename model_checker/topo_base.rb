require_relative 'topo_diff'

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
      @attribute = {}
      @supports = []
      @diff_state = nil
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
      key_klass_list.each do |list|
        next unless data.key?(list[:key])
        @attribute = list[:klass].new(data[list[:key]])
      end
    end

    def setup_supports(data, key, klass)
      return unless data.key?(key)
      @supports = data[key].map do |support|
        klass.new(support)
      end
    end
  end
end
