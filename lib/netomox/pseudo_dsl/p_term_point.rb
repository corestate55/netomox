# frozen_string_literal: true

require_relative 'p_object_base'

module Netomox
  module PseudoDSL
    # pseudo termination point
    class PTermPoint < PObjectBase
      # @return [String] String
      def to_s
        "[#{name}]"
      end
    end
  end
end
