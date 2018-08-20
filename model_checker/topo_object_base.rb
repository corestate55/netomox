module TopoChecker
  # Toloplogy Object Base
  class TopoObjectBase
    attr_reader :name, :path, :attribute, :supports

    def initialize(name, parent_path = '')
      @name = name
      @parent_path = parent_path
      @path = parent_path.empty? ? @name : [@parent_path, @name].join('/')
    end

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      @name == other.name
    end

    protected

    def setup_attribute(data, key_klass_list)
      # key_klass_list = [{key: 'NAMESPACE:attr_key', klass: class_name}..]
      # NOTICE: WITHOUT network type checking
      @attribute = {}
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
