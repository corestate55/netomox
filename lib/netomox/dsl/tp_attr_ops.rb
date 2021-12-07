# frozen_string_literal: true

require 'netomox/dsl/base_attr_ops'

module Netomox
  module DSL
    # attribute for ops-topology node
    class OpsTPAttribute < OpsAttributeBase
      # @param [Hash] hash Key-Value data of any attribute
      def initialize(hash)
        super(hash)
        @type = "#{NS_OPS}:ops-termination-point-attributes"
      end
    end
  end
end
