# frozen_string_literal: true

module Netomox
  module DSL
    # Attribute base for ops-topology: key-value style multi-purpose attribute.
    class OpsAttributeBase
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [Hash] hash Key-Value data of any attribute
      def initialize(hash)
        @attr = hash || {}
        @type = "#{NS_OPS}:ops-attribute-base" # to be override
      end

      # does the method exists as instance method?
      # @param [String] method Method name (attribute key)
      # @param [Boolean] include_private
      # @return [Boolean]
      def respond_to_missing?(method, include_private = false)
        @attr.key?(method) ? true : super
      end

      # To be respond any attribute Key as accessor (instance method)
      # @param [String] method Attribute keyword (want to access as property)
      def method_missing(method, *args)
        # attribute hash key to (ghost) method: read-only (same-as attr_reader)
        @attr.key?(method) ? @attr[method] : super
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        @attr
      end

      # @return [Boolean]
      def empty?
        @attr.empty?
      end
    end
  end
end
