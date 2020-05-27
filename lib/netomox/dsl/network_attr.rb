# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/attr_base'

module Netomox
  module DSL
    # network attribute base
    class NetworkAttributeBase
      attr_accessor :name, :flags
      attr_reader :type

      def initialize(name: '', flags: [])
        @name = name
        @flags = flags
        @type = ''
      end

      def topo_data
        {
          'name' => @name,
          'flag' => @flags
        }
      end

      def empty?
        @name.empty? && @flags.empty?
      end
    end

    # attributes for L3 network
    class L3NWAttribute < NetworkAttributeBase
      def initialize(name: '', flags: [])
        super(name: name, flags: flags)
        @type = "#{NS_L3NW}:l3-topology-attributes"
      end
    end

    # attributes for L2 network
    class L2NWAttribute < NetworkAttributeBase
      def initialize(name: '', flags: [])
        super(name: name, flags: flags)
        @type = "#{NS_L2NW}:l2-network-attributes"
      end
    end

    # multi-purpose
    class MultiPurposeNWAttribute < MultiPurposeAttributeBase
      def initialize(hash)
        super(hash)
        @type = 'multi-purpose-network-attributes'
      end
    end
  end
end
