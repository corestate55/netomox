# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # Link attribute base
    #   TBA: Not defined yet, reserve class names
    class MddoLinkAttributeBase < AttributeBase
      # TBA
      ATTR_DEFS = [].freeze

      # @param [Hash] data Data in RFC8345
      # @param [String] type Keyword of data
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@path}"
      end
    end

    # Attribute definition of MDDO L1 link
    class MddoL1LinkAttribute < MddoLinkAttributeBase; end
    # Attribute definition of MDDO L2 link
    class MddoL2LinkAttribute < MddoLinkAttributeBase; end
    # Attribute definition of MDDO L3 link
    class MddoL3LinkAttribute < MddoLinkAttributeBase; end
  end
end
