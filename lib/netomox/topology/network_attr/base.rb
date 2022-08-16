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

      # Attribute definition of network
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      # @param [Array<Hash>] attr_table Attribute data
      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(attr_table, data, type)
        super(ATTR_DEFS + attr_table, data, type) # merge ATTR_DEFS
      end

      # @return [String]
      def to_s
        "attribute:#{@name},#{@flags}"
      end
    end
  end
end
