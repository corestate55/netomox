module Netomox
  module DSL
    # DSl common methods
    class DSLObjectBase
      attr_accessor :parent, :name, :path

      def initialize(parent, name)
        @parent = parent
        @name = name
        @path = @name # for networks (parent == nil)
        @path = [@parent.path, @name].join('__') unless @parent.nil?
      end

      def register(&block)
        instance_eval(&block)
      end
    end
  end
end
