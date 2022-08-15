# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # Port VLAN ID & Name, for L2 attribute
    class L2VlanIdName < AttributeBase
      # @!attribute [rw] id
      #   @return [Integer]
      # @!attribute [rw] name
      #   @return [String]
      attr_accessor :id, :name

      # Attribute definition of Port VLAN ID & Name for L2 network
      ATTR_DEFS = [
        { int: :id, ext: 'vlan-id', default: 0 },
        { int: :name, ext: 'vlan-name', default: '' }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "VLAN: #{@id},#{@name}"
      end
    end
  end
end
