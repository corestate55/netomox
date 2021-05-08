# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/diff_forward'

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

    # L3 prefix for L3 attribute
    class L3Prefix < AttributeBase
      # @!attribute [rw] prefix
      #   @return [String]
      # @!attribute [rw] metric
      #   @return [Integer]
      # @!attribute [rw] flag
      #   @return [Array<String>]
      attr_accessor :prefix, :metric, :flag

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

    # attribute for L3 node
    class L3NodeAttribute < AttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      # @!attribute [rw] router_id
      #   @return [String]
      # @!attribute [rw] prefixes
      #   @return [Array<L3Prefix>]
      attr_accessor :name, :flags, :router_id, :prefixes

      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :flags, ext: 'flag', default: [] },
        { int: :router_id, ext: 'router-id', default: '' },
        { int: :prefixes, ext: 'prefix', default: [] }
      ].freeze

      include Diffable
      include SubAttributeOps

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        setup_prefixes(data)
      end

      # @return [String]
      def to_s
        "attribute: #{@name}"
      end

      # @param [L3NodeAttribute] other Target to compare
      # @return [L3NodeAttribute]
      def diff(other)
        diff_of(:prefixes, other)
      end

      # Fill diff state
      # @param [Hash] state_hash
      # @return [L3NodeAttribute]
      def fill(state_hash)
        fill_of(:prefixes, state_hash)
      end

      private

      def setup_prefixes(data)
        @prefixes = if data.key?('prefix')
                      data['prefix'].map { |p| L3Prefix.new(p, 'prefix') }
                    else
                      []
                    end
      end
    end
  end
end
