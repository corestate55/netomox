# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # attribute for L2 link
    class L2LinkAttribute < AttributeBase
      # @!attribute [rw] name
      #   @return [string]
      # @!attribute [rw] flags
      #   @return [Array<<String>]
      # @!attribute [rw] rate
      #   @return [Integer]
      # @!attribute [rw] delay
      #   @return [Integer]
      # @!attribute [rw] srlg
      #   @return [String]
      attr_accessor :name, :flags, :rate, :delay, :srlg

      # Attribute definition of L2 link
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :flags, ext: 'flag', default: [] },
        { int: :rate, ext: 'rate', default: 0 },
        { int: :delay, ext: 'delay', default: 0 },
        { int: :srlg, ext: 'srlg', default: '' }
      ].freeze

      # @param [Hash] data Data in RFC8345
      # @param [String] type Keyword of data
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@name}"
      end
    end

    # attribute for L3 link
    class L3LinkAttribute < AttributeBase
      # @!attribute [rw] name
      #   @return [string]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      # @!attribute [rw] metric1
      #   @return [Integer]
      # @!attribute [rw] metric2
      #   @return [Integer]
      attr_accessor :name, :flags, :metric1, :metric2

      # Attribute definition of L3 link
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :flags, ext: 'flag', default: [] },
        { int: :metric1, ext: 'metric1', default: 0 },
        { int: :metric2, ext: 'metric2', default: 0 }
      ].freeze

      # @param [Hash] data Data in RFC8345
      # @param [String] type Keyword of data
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@name}"
      end
    end
  end
end
