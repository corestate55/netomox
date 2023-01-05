# frozen_string_literal: true

module Netomox
  module PseudoDSL
    # base class for pseudo network object
    class PObjectBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] attribute
      #   @return [Hash]
      # @!attribute [rw] supports
      #   @return [Array<(String, Array<String>)>]
      #   @note `[nw_name,..]` for network,
      #     `[[nw_name, node_name],..]` for node,
      #     `[[nw_name, node_name, tp_name],...]` for tp
      attr_accessor :name, :attribute, :supports

      # @param [String] name Name of the object
      def initialize(name)
        @name = name
        @attribute = nil
        @supports = []
      end
    end

    # base class for pseudo link
    class PLinkEdge
      # @!attribute [rw] node
      #   @return [String]
      # @!attribute [rw] tp
      #   @return [String]
      attr_accessor :node, :tp

      # @param [String] node_name Node name
      # @param [String] tp_name Term-point name (on the node)
      def initialize(node_name, tp_name)
        @node = node_name
        @tp = tp_name
      end

      # @return [Boolean] true if equal
      def ==(other)
        @node == other.node && @tp == other.tp
      end

      # @return [String] String
      def to_s
        "#{node}[#{tp}]"
      end
    end
  end
end
