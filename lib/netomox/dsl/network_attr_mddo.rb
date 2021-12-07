# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/base_attr_rfc'

module Netomox
  module DSL
    class MddoL1NWAttribute < NetworkAttributeBase
      def initialize(**hash)
        super(**hash)
        @type = "#{NS_MDDO}:l1-network-attributes"
      end
    end

    class MddoL2NWAttribute < NetworkAttributeBase
      def initialize(**hash)
        super(**hash)
        @type = "#{NS_MDDO}:l2-network-attributes"
      end
    end

    class MddoL3NWAttribute < NetworkAttributeBase
      def initialize(**hash)
        super(**hash)
        @type = "#{NS_MDDO}:l3-network-attributes"
      end
    end
  end
end
