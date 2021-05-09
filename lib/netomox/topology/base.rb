# frozen_string_literal: true

require 'netomox/topology/diff'
require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # Topology Object Base
    class TopoObjectBase
      attr_reader :name, :path
      attr_accessor :diff_state, :attribute, :supports

      include Diffable

      # @param [String] name Object name
      # @param [String] parent_path Parent ofject path
      def initialize(name, parent_path = '')
        @name = name
        @parent_path = parent_path
        @path = parent_path.empty? ? @name : [@parent_path, @name].join('__')
        @diff_state = DiffState.new # empty state
      end

      # @param [TopoObjectBase] other Target topology object
      # @return [Boolean]
      def ==(other)
        eql?(other)
      end

      # @param [TopoObjectBase] other Target topology object
      # @return [Boolean]
      def eql?(other)
        @path == other.path
      end

      # seems empty (if nameless object)
      # @return [Boolean]
      def empty?
        @name.empty?
      end

      protected

      def add_supports_and_attr(data, supports_key)
        # "support-" key is same each network/node/link/tp,
        # but attribute key is different not only object type
        # but also network type.
        # so that, @attribute has type when the instance initialized.
        data[supports_key] = @supports.map(&:to_data) unless @supports.empty?
        data[@attribute.type] = @attribute.to_data unless @attribute.empty?
        data
      end

      def setup_attribute(data, key_klass_list)
        # key_klass_list =
        #   [ { key: 'NAMESPACE:attr_key', klass: class_name },...]
        # NOTICE: WITHOUT network type checking
        # empty attribute (default) to calculate diff
        @attribute = AttributeBase.new([], {}, '_empty_attr_')
        key_klass_list.each do |list|
          next unless data.key?(list[:key])

          @attribute = list[:klass].new(data[list[:key]], list[:key])
        end
      end

      def setup_supports(data, key, klass)
        @supports = []
        return unless data.key?(key)

        @supports = data[key].map do |support|
          klass.new(support)
        end
      end
    end
  end
end
