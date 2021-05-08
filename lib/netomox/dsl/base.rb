# frozen_string_literal: true

module Netomox
  module DSL
    # DSl common methods
    class DSLObjectBase
      # @!attribute [rw] parent
      #   @return [String] Parent object path
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] path
      #   @return [String]
      attr_accessor :parent, :name, :path

      # @param [DSLObjectBase] parent Parent object
      # param [String] name Object name
      def initialize(parent, name)
        @parent = parent
        @name = name
        @path = @name # for networks (parent == nil)
        @path = [@parent.path, @name].join('__') unless @parent.nil?
      end

      # @param [Proc] block Code Block to eval in this instance
      def register(&block)
        instance_eval(&block)
      end
    end
  end
end
