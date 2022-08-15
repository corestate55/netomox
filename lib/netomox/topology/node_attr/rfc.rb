# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/node_attr/base'

module Netomox
  module Topology
    # attribute for L2 node
    class L2NodeAttribute < AttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] descr
      #   @return [String]
      # @!attribute [rw] mgmt_addrs
      #   @return [Array<String>]
      # @!attribute [rw] sys_mac_addr
      #   @return [String]
      # @!attribute [rw] mgmt_vid
      #   @return [Integer]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :name, :descr, :mgmt_addrs, :sys_mac_addr, :mgmt_vid, :flags

      # Attribute definition of L2 node
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :descr, ext: 'description', default: '' },
        { int: :mgmt_addrs, ext: 'management-address', default: [] },
        { int: :sys_mac_addr, ext: 'sys-mac-address', default: '' },
        { int: :mgmt_vid, ext: 'management-vid', default: 0 },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@name}"
      end
    end

    # attribute for L3 node
    class L3NodeAttribute < L3NodeAttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      # @!attribute [rw] router_id
      #   @return [String]
      attr_accessor :name, :flags, :router_id

      # Attribute definition of L3 node
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :flags, ext: 'flag', default: [] },
        { int: :router_id, ext: 'router-id', default: '' }
      ].freeze

      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end
  end
end
