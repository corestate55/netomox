# frozen_string_literal: true

module Netomox
  module Topology
    # one record of attribute table
    class AttributeTableLine
      attr_reader :int, :ext, :default, :check

      def initialize(int:, ext:, default: '')
        @int = int
        @ext = ext
        @default = default
        setup_check
      end

      private

      def setup_check
        @check = case @default
                 when [], '' then :empty?
                 when 0 then :zero?
                 else false # ignore empty check
                 end
      end
    end

    # attribute key table/converter
    class AttributeTable
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
        @lines = lines.map { |line| AttributeTableLine.new(line) }
      end

      def int_keys
        # return internal key list (variable names of attribute)
        @lines.map(&:int)
      end

      def int_keys_with_empty_check
        # return keys to except empty check
        keys = @lines.find_all(&:check)
        keys.map(&:int)
      end

      def ext_of(int_key)
        find_line_by(int_key).ext
      end

      def default_of(int_key)
        find_line_by(int_key).default
      end

      def check_of(int_key)
        find_line_by(int_key).check
      end

      def find_line_by(int_key)
        @lines.find { |d| d.int == int_key }
      end
    end
  end
end
