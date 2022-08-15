# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/diff_forward'

module Netomox
  module Topology
    # attribute for L1 termination point
    class MddoL1TPAttribute < AttributeBase
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :description, :flags

      # Attribute definition of L1 termination-point
      ATTR_DEFS = [
        { int: :description, ext: 'description', default: '' },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@path}"
      end
    end

    # attribute for L2 termination point
    class MddoL2TPAttribute < AttributeBase
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] encapsulation
      #   @return [String]
      # @!attribute [rw] switchport_mode
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :description, :encapsulation, :switchport_mode, :flags

      # Attribute definition of L2 termination-point
      ATTR_DEFS = [
        { int: :description, ext: 'description', default: '' },
        { int: :encapsulation, ext: 'encapsulation', default: '' },
        { int: :switchport_mode, ext: 'switchport-mode', default: '' },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@path}"
      end
    end

    # attribute for L3 termination point
    class MddoL3TPAttribute < AttributeBase
      # @!attribute [rw] description
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :description, :ip_addrs, :flags

      # Attribute definition of L2 termination-point
      ATTR_DEFS = [
        { int: :description, ext: 'description', default: '' },
        { int: :ip_addrs, ext: 'ip-address', default: [] },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@path}"
      end
    end
  end
end
