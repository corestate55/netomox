# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # attribute for mddo-topology layer1 term-point
    class MddoL1TPAttribute
      # @!attribute [rw] description
      #   @return [String]
      attr_accessor :description
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] description Interface description
      def initialize(description: '')
        @description = description
        @type = "#{NS_MDDO}:l1-termination-point-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'description' => @description
        }
      end

      # @return [Boolean]
      def empty?
        @description.empty?
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
      attr_accessor :description, :encapsulation, :switchport_mode
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] description Interface description
      def initialize(description: '', encapsulation: '', switchport_mode: '')
        @description = description
        @encapsulation = encapsulation
        @switchport_mode = @switchport_mode
        @type = "#{NS_MDDO}:l2-termination-point-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'description' => @description,
          'encapsulation' => @encapsulation,
          'switchport-mode' => @switchport_mode
        }
      end

      # @return [Boolean]
      def empty?
        @description.empty? && @encapsulation.empty? && @switchport_mode.empty?
      end
    end

    # attribute for mddo-topology layer3 term-point
    class MddoL3TPAttribute
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] ip_address
      #   @return [String]
      attr_accessor :description, :ip_address
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] description Interface description
      def initialize(description: '', ip_address: '')
        @description = description
        @ip_address = ip_address
        @type = "#{NS_MDDO}:l3-termination-point-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'description' => @description,
          'ip-address' => @ip_address
        }
      end

      # @return [Boolean]
      def empty?
        @description.empty? && @ip_address.empty?
      end
    end
  end
end
