# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # network attribute base
    class NetworkAttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :name, :flags
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] name
      # @param [Array<String>] flags
      def initialize(name: '', flags: [])
        @name = name
        @flags = flags
        @type = ''
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'flag' => @flags
        }
      end

      # @return [Boolean]
      def empty?
        @name.empty? && @flags.empty?
      end
    end
  end
end
