# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/node_attr/base'

module Netomox
  module Topology
    # attribute for L1 node
    class MddoL1NodeAttribute < AttributeBase
      # @!attribute [rw] os_type
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :os_type, :flags

      # Attribute definition of L1 node
      ATTR_DEFS = [
        { int: :os_type, ext: 'os-type', default: '' },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (MDDO)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@name}"
      end
    end

    # attribute for L2 node
    class MddoL2NodeAttribute < AttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] vlan_id
      #   @return [Integer]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :name, :vlan_id, :flags

      # Attribute definition of L1 node
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :vlan_id, ext: 'vlan-id', default: 0 },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (MDDO)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@name}"
      end
    end

    # attribute for L3 2node
    class MddoL3NodeAttribute < L3NodeAttributeBase
      # @!attribute [rw] node_type
      #   @return [String]
      attr_accessor :node_type

      # Attribute definition of L1 node
      ATTR_DEFS = [
        { int: :node_type, ext: 'node-type', default: '' },
        { int: :prefixes, ext: 'prefix', default: [] }
      ].freeze

      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end
  end
end
