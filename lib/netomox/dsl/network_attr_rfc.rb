# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/base_attr_rfc'

module Netomox
  module DSL
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
  end
end
