# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/base_attr/rfc'

module Netomox
  module DSL
    # attribute for mddo-topology layer1 network
    class MddoL1NWAttribute < NetworkAttributeBase
      def initialize(**hash)
        super(**hash)
        @type = "#{NS_MDDO}:l1-network-attributes"
      end
    end

    # attribute for mddo-topology layer2 network
    class MddoL2NWAttribute < NetworkAttributeBase
      def initialize(**hash)
        super(**hash)
        @type = "#{NS_MDDO}:l2-network-attributes"
      end
    end

    # attribute for mddo-topology layer3 network
    class MddoL3NWAttribute < NetworkAttributeBase
      def initialize(**hash)
        super(**hash)
        @type = "#{NS_MDDO}:l3-network-attributes"
      end
    end

    # attribute for mddo-topology ospf-area network
    class MddoOspfAreaNWAttribute < NetworkAttributeBase
      # @!attribute identifier
      #   @return [String]
      #   @note dotted-quad astring
      attr_accessor :identifier

      # @param [String] name Network name
      # @param [String] identifier OSPF area ID (dotted-quad)
      # @param [Array<String>] flags
      def initialize(name: '', identifier: '', flags: [])
        super(name:, flags:)
        @identifier = identifier
        @type = "#{NS_MDDO}:ospf-area-network-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'identifier' => @identifier,
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @name.empty? && @identifier.empty? && @flags.empty?
      end
    end

    # attribute for mddo-topology bgp-proc network
    class MddoBgpProcNWAttribute < NetworkAttributeBase
      def initialize(**hash)
        super(**hash)
        @type = "#{NS_MDDO}:bgp-proc-network-attributes"
      end
    end

    # attribute for mddo-topology bgp-as network
    class MddoBgpAsNWAttribute < NetworkAttributeBase
      def initialize(**hash)
        super(**hash)
        @type = "#{NS_MDDO}:bgp-as-network-attributes"
      end
    end
  end
end
