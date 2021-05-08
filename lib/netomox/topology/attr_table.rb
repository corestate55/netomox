# frozen_string_literal: true

module Netomox
  module Topology
    # one record of attribute table
    class AttributeTableLine
      attr_reader :int, :ext, :default, :empty_check

      # @param [Symbol] int Internal attribute keyword (as property/method name)
      # @param [String] ext External attribute keyword (for YANG or other data files)
      # @param [String] default Default value
      def initialize(int:, ext:, default: '')
        @int = int
        @ext = ext
        @default = default
        setup_empty_check_method
      end

      private

      def setup_empty_check_method
        @empty_check = case @default
                       when [], '' then :empty?
                       when 0 then :zero?
                       else false # ignore empty check
                       end
      end
    end

    # attribute key table/converter
    class AttributeTable
      # @param [Array<Hash>] lines Attribute definition data table
      def initialize(lines)
        # lines = [
        #   {
        #     int: :AttributeBase_member_name,
        #     ext: 'JSON-key-name',
        #     default: default_value,
        #     check: :empty_check_method_symbol (:empty? :zero? or false)
        #   },
        #   ....
        # ]
        @lines = lines.map { |line| AttributeTableLine.new(**line) }
      end

      # @return [Array<Symbol>] Internal keys (variable names of attribute)
      def int_keys
        @lines.map(&:int)
      end

      # @return [Array<Symbol>] Internal keys (to check except empty)
      def int_keys_with_empty_check
        keys = @lines.find_all(&:empty_check)
        keys.map(&:int)
      end

      # @param [Symbol] int_key Internal keyword
      # @return [String] external keyword of int_key
      def ext_of(int_key)
        find_line_by(int_key).ext
      end

      # @param [Symbol] int_key Internal keyword
      # @return [String] default value of int_key
      def default_of(int_key)
        find_line_by(int_key).default
      end

      # @param [Symbol] int_key Internal keyword
      # @return [Symbol] Method to check empty
      # @return [Boolean] false if the attribute does not have empty check method
      def check_of(int_key)
        find_line_by(int_key).empty_check
      end

      # @param [Symbol] int_key Internal keyword
      # @return [AttributeTableLine]
      def find_line_by(int_key)
        @lines.find { |d| d.int == int_key }
      end
    end
  end
end
