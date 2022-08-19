# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/node_attr/base'
require 'netomox/topology/node_attr/mddo_l3_static_route'
require 'netomox/topology/node_attr/mddo_ospf_redistribute'

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

      # Attribute definition of L2 node
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

    # attribute for L3 node
    class MddoL3NodeAttribute < L3NodeAttributeBase
      # @!attribute [rw] node_type
      #   @return [String]
      # @!attribute [rw] static_routes
      #   @return []
      attr_accessor :node_type, :static_routes

      # Attribute definition of L3 node
      ATTR_DEFS = [
        { int: :node_type, ext: 'node-type', default: '' },
        { int: :static_routes, ext: 'static-route', default: [] }
      ].freeze

      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @static_routes = convert_static_routes(data)
      end

      # @param [MddoL3NodeAttribute] other target to compare
      # @return [MddoL3NodeAttribute]
      def diff(other)
        super(other)
        diff_of(:static_routes, other)
      end

      # @param [Hash] state_hash
      # @return [void]
      def fill(state_hash)
        super(state_hash)
        fill_of(:static_routes, state_hash)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<L3Prefix>] Converted attribute data
      def convert_static_routes(data)
        key = @attr_table.ext_of(:static_routes)
        operative_array_key?(data, key) ? data[key].map { |s| MddoL3StaticRoute.new(s, key) } : []
      end
    end

    # attribute for ospf-area node
    class MddoOspfAreaNodeAttribute < AttributeBase
      # @!attribute [rw] node_type
      #   @return [String]
      # @!attribute [rw] router_id
      #   @return [String]
      #   @note dotted-quad string
      # @!attribute [rw] log_adjacency_change
      #   @return [Boolean]
      # @!attribute [rw] redistribute_list
      #   @return [Array<MddoOspfRedistribute>]
      # @!attribute [r] router_id_source
      #   @return [Symbol]
      #   @todo enum (:static, :auto)
      attr_accessor :node_type, :router_id, :log_adjacency_change, :redistribute_list, :router_id_source

      # Attribute definition of ospf-area node
      ATTR_DEFS = [
        { int: :node_type, ext: 'node-type', default: '' },
        { int: :router_id, ext: 'router-id', default: '' },
        { int: :log_adjacency_change, ext: 'log-adjacency-change', default: false },
        { int: :redistribute_list, ext: 'redistribute', default: [] },
        { int: :router_id_source, ext: 'router-id-source', default: 'dynamic' }
      ].freeze

      include Diffable
      include SubAttributeOps

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @redistribute_list = convert_redistribute_list(data)
      end

      # @return [String]
      def to_s
        "attribute: #{@name}"
      end

      # @param [MddoOspfAreaNodeAttribute] other Target to compare
      # @return [MddoOspfAreaNodeAttribute]
      def diff(other)
        diff_of(:redistribute_list, other)
      end

      # Fill diff state
      # @param [Hash] state_hash
      # @return [void]
      def fill(state_hash)
        fill_of(:redistribute_list, state_hash)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<L3Prefix>] Converted attribute data
      def convert_redistribute_list(data)
        key = @attr_table.ext_of(:redistribute_list)
        operative_array_key?(data, key) ? data[key].map { |p| MddoOspfRedistribute.new(p, key) } : []
      end
    end
  end
end
