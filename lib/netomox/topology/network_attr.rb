# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # base class for network topology
    class NetworkAttributeBase < AttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :name, :flags

      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute:#{@name},#{@flags}"
      end
    end

    # attribute for L2 network
    class L2NetworkAttribute < NetworkAttributeBase; end
    # attribute for L3 network
    class L3NetworkAttribute < NetworkAttributeBase; end
  end
end
