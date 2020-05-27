module Netomox
  module DSL
    class MultiPurposeAttributeBase
      attr_reader :type

      def initialize(hash)
        @attr = hash || {}
        @type = 'multi-purpose-attribute-base' # to be override
      end

      def respond_to_missing?(method, include_private=false)
        @attr.has_key?(method) ? true : super
      end

      def method_missing(method, *args)
        # attribute hash key to (ghost) method: read-only (same-as attr_reader)
        @attr.has_key?(method) ? @attr[method] : super
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
