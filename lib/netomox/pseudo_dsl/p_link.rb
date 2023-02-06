# frozen_string_literal: true

require_relative 'p_object_base'

module Netomox
  module PseudoDSL
    # pseudo link
    class PLink
      # @!attribute [rw] src
      #   @return [PLinkEdge]
      # @!attribute [rw] dst
      #   @return [PLinkEdge]
      attr_accessor :src, :dst

      # @param [PLinkEdge] src Source link-edge
      # @param [PLinkEdge] dst Destination link-edge
      def initialize(src, dst)
        @src = src
        @dst = dst
      end

      # @return [String]
      def to_s
        "#{src} > #{dst}"
      end
    end
  end
end
