# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # L3 prefix for L3 attribute
    class L3Prefix < SubAttributeBase
      # @!attribute [rw] prefix
      #   @return [String]
      # @!attribute [rw] metric
      #   @return [Integer]
      # @!attribute [rw] flag
      #   @return [Array<String>]
      attr_accessor :prefix, :metric, :flag

      # Attribute definition of L3 prefix ()for L3 node)
      ATTR_DEFS = [
        { int: :prefix, ext: 'prefix', default: '' },
        { int: :metric, ext: 'metric', default: 0 },
        { int: :flag, ext: 'flag', default: '' }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end
  end
end
