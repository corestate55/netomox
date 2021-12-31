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
        @path = parent_path.empty? ? @name : make_path
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

      # Rename object name (Notice: dangerous method)
      # @param [String] name New name of the object.
      def rename!(name)
        @name = name
        @path = make_path
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

      def setup_diff_state(data)
        ds_key = '_diff_state_'.freeze
        return unless data[ds_key]

        @diff_state = DiffState.new(
          forward: data[ds_key]['forward']&.intern,
          backward: data[ds_key]['backward']&.intern,
          pair: data[ds_key]['pair']
        )
      end

      private

      def make_path
        [@parent_path, @name].join('__')
      end
    end
  end
end
