# frozen_string_literal: true

module Netomox
  module DSL
    # Error for Netomox::DSL
    class DSLError < StandardError; end
    # Error when invalid argument in DSL
    class DSLInvalidArgumentError < DSLError; end
  end
end
