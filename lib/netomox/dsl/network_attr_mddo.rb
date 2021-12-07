# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/base_attr_rfc'

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
  end
end
