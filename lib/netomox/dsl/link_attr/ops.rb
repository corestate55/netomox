# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/base_attr/ops'

module Netomox
  module DSL
    # attribute for ops-topology link
    class OpsLinkAttribute < OpsAttributeBase
      # @param [Hash] hash Key-Value data of any attribute
      def initialize(hash)
        super(hash)
        @type = "#{NS_OPS}:ops-link-attributes"
      end
    end
  end
end
