# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # attribute for mddo-topology layer1 term-point
    class MddoL1TPAttribute
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :description, :flags
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] description Interface description
      # @param [Array<String>] flags Flags
      def initialize(description: '', flags: [])
        @description = description || '' # avoid nil if the interface doesn't have description
        @flags = flags
        @type = "#{NS_MDDO}:l1-termination-point-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'description' => @description,
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @description.empty? && @flags.empty?
      end
    end

    # attribute for mddo-topology layer2 term-point
    class MddoL2TPAttribute
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] encapsulation
      #   @return [String]
      # @!attribute [rw] switchport_mode
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :description, :encapsulation, :switchport_mode, :flags
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] description Interface description
      # @param [String] encapsulation VLAN encapsulation
      # @param [String] switchport_mode Switch-port mode
      # @param [Array<String>] flags Flags
      def initialize(description: '', encapsulation: '', switchport_mode: '', flags: [])
        @description = description || '' # avoid nil if the interface doesn't have description
        @encapsulation = encapsulation
        @switchport_mode = switchport_mode
        @flags = flags
        @type = "#{NS_MDDO}:l2-termination-point-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'description' => @description,
          'encapsulation' => @encapsulation,
          'switchport-mode' => @switchport_mode,
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @description.empty? && @encapsulation.empty? && @switchport_mode.empty? && flags.empty?
      end
    end

    # attribute for mddo-topology layer3 term-point
    class MddoL3TPAttribute
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] ip_addrs
      #   @return [Array<String>]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :description, :ip_addrs, :flags
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] description Interface description
      # @param [Array<String>] ip_addrs IP addresses
      # @param [Array<String>] flags Flags
      def initialize(description: '', ip_addrs: [], flags: [])
        @description = description || '' # avoid nil if the interface doesn't have description
        @ip_addrs = ip_addrs
        @flags = flags
        @type = "#{NS_MDDO}:l3-termination-point-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'description' => @description,
          'ip-address' => @ip_addrs,
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @description.empty? && @ip_addrs.empty? && @flags.empty?
      end
    end
  end
end
