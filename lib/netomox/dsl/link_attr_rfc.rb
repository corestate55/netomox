# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # attribute for L3 link
    class L3LinkAttribute
      # @!attribute [rw] name
      #   @return [string]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      # @!attribute [rw] metric1
      #   @return [Integer]
      # @!attribute [rw] metric2
      #   @return [Integer]
      attr_accessor :name, :flags, :metric1, :metric2
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] name
      # @param [Array<String>] flags
      # @param [Integer] metric1
      # @param [Integer] metric2
      def initialize(name: '', flags: [], metric1: nil, metric2: nil)
        @name = name
        @flags = flags
        @metric1 = metric1
        @metric2 = metric2
        @type = "#{NS_L3NW}:l3-link-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'flag' => @flags,
          'metric1' => @metric1,
          'metric2' => @metric2
        }
      end

      # @return [Boolean]
      def empty?
        @name.empty? && @flags.empty? && @metric1.nil? && @metric2.nil?
      end
    end

    # attribute for L2 link
    class L2LinkAttribute
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
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      # @param [String] name
      # @param [Array<String>] flags
      # @param [Integer] rate
      # @param [Integer] delay
      # @param [String] srlg
      def initialize(name: '', flags: [], rate: nil, delay: nil, srlg: '')
        @name = name
        @flags = flags
        @rate = rate
        @delay = delay
        @srlg = srlg
        @type = "#{NS_L2NW}:l2-link-attributes"
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'flag' => @flags,
          'rate' => @rate,
          'delay' => @delay,
          'srlg' => @srlg
        }
      end

      # @return [Boolean]
      def empty?
        @name.empty? && @flags.empty? && \
          @rate.nil? && @delay.nil? && @srlg.empty?
      end
    end
  end
end
