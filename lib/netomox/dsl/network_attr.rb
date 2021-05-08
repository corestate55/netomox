# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/attr_base'

module Netomox
  module DSL
    # network attribute base
    class NetworkAttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :name, :flags
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] name
      # @param [Array<String>] flags
      def initialize(name: '', flags: [])
        @name = name
        @flags = flags
        @type = ''
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @name.empty? && @flags.empty?
      end
    end

    # attributes for L3 network
    class L3NWAttribute < NetworkAttributeBase
      # @param [String] name
      # @param [Array<String>] flags
      def initialize(name: '', flags: [])
        super(name: name, flags: flags)
        @type = "#{NS_L3NW}:l3-topology-attributes"
      end
    end

    # attributes for L2 network
    class L2NWAttribute < NetworkAttributeBase
      # @param [String] name
      # @param [Array<String>] flags
      def initialize(name: '', flags: [])
        super(name: name, flags: flags)
        @type = "#{NS_L2NW}:l2-network-attributes"
      end
    end

    # attribute for ops-topology network
    class OpsNWAttribute < OpsAttributeBase
      # @param [Hash] hash Key-Value data of any attribute
      def initialize(hash)
        super(hash)
        @type = "#{NS_OPS}:ops-network-attributes"
      end
    end
  end
end
