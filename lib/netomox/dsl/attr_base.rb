# frozen_string_literal: true

module Netomox
  module DSL
    # Attribute base for ops-topology: key-value style multi-purpose attribute.
    class OpsAttributeBase
      attr_reader :type

      def initialize(hash)
        @attr = hash || {}
        @type = "#{NS_OPS}:ops-attribute-base" # to be override
      end

      def respond_to_missing?(method, include_private = false)
        @attr.key?(method) ? true : super
      end

      def method_missing(method, *args)
        # attribute hash key to (ghost) method: read-only (same-as attr_reader)
        @attr.key?(method) ? @attr[method] : super
      end

      def topo_data
        @attr
      end

      def empty?
        @attr.empty?
      end
    end
  end
end
