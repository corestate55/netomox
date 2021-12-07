# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/node_attr_rfc_prefix'

module Netomox
  module DSL
    # attribute for L3 node
    class L3NodeAttribute
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      # @!attribute [rw] router_id
      #   @return [String]
      # @!attribute [rw] prefixes
      #   @return [Array<L3Prefix>]
      attr_accessor :name, :flags, :router_id, :prefixes
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] name
      # @param [Array<String>] flags
      # @param [String] router_id
      # @param [Array<L3Prefix>] prefixes
      def initialize(name: '', flags: [], router_id: '', prefixes: [])
        @name = name
        @flags = flags
        @router_id = router_id
        @prefixes = prefixes.empty? ? [] : prefixes.map { |p| L3Prefix.new(**p) }
        @type = "#{NS_L3NW}:l3-node-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      # @todo router-id is now single value, but it must be leaf-list
      def topo_data
        {
          'name' => @name,
          'flag' => @flags,
          'router-id' => [@router_id],
          'prefix' => @prefixes.map(&:topo_data)
        }
      end

      # @return [Boolean]
      def empty?
        @name.empty? && @flags.empty? && @router_id.empty? && @prefixes.empty?
      end
    end

    # attribute for L2 node
    class L2NodeAttribute
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      # @!attribute [rw] descr
      #   @return [String]
      # @!attribute [rw] mgmt_addrs
      #   @return [Array<String>]
      # @!attribute [rw] sys_mac_addr
      #   @return [String]
      # @!attribute [rw] mgmt_vid
      #   @return [Integer]
      attr_accessor :name, :flags, :descr, :mgmt_addrs, :sys_mac_addr, :mgmt_vid
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] name
      # @param [Array<String>] flags
      # @param [String] descr
      # @param [Array<String>] mgmt_addrs
      # @param [String] sys_mac_addr
      # @param [Integer] mgmt_vid
      # rubocop:disable Metrics/ParameterLists
      def initialize(name: '', flags: [], descr: '',
                     mgmt_addrs: [], sys_mac_addr: '', mgmt_vid: 0)
        @name = name
        @flags = flags
        @descr = descr
        @mgmt_addrs = mgmt_addrs
        @sys_mac_addr = sys_mac_addr
        @mgmt_vid = mgmt_vid
        @type = "#{NS_L2NW}:l2-node-attributes"
      end
      # rubocop:enable Metrics/ParameterLists

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'description' => @descr,
          'management-address' => @mgmt_addrs,
          'sys-mac-address' => @sys_mac_addr,
          'management-vid' => @mgmt_vid,
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @name.empty? && @flags.empty? && @descr.empty? \
      && @mgmt_addrs.empty? && @sys_mac_addr.empty? && @mgmt_vid.empty?
      end
    end
  end
end
