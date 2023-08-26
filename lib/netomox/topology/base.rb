# frozen_string_literal: true

require 'netomox/topology/diffable'
require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # Topology Object Base
    class TopoObjectBase
      attr_reader :name, :path, :parent_path
      attr_accessor :diff_state, :attribute, :supports

      include Diffable

      # @param [String] name Object name
      # @param [String] parent_path Parent object path
      def initialize(name, parent_path = '')
        @name = name
        @parent_path = parent_path
        @path = parent_path.empty? ? @name : make_path
        @diff_state = DiffState.new # empty state
      end

      # @return [Array<String>] List of path element
      def path_list
        @path.split('__')
      end

      # @return [String,nil] Parent object name
      #   (nil then parent path = ''(empty string))
      def parent_name
        @parent_path.split('__').last
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

      # add supports and attribute key to #to_data output hash (converted data)
      # @param [Hash] data RFC8345 data (#to_data target)
      # @return [Hash] RFC8345 data (with supports, attribute)
      def add_supports_and_attr(data, supports_key)
        # "support-" key is same each network/node/link/tp,
        # although attribute key is different not only object type but also network-type.
        # so that, @attribute has type when the instance initialized.
        data[supports_key] = @supports.map(&:to_data) unless @supports.empty?
        data[@attribute.type] = @attribute.to_data unless @attribute.empty?
        data
      end

      # @param [hash] data RFC8345 data
      # @param [Array<Hash>] key_klass_list Array of attribute-key/class hash
      # @return [void]
      def setup_attribute(data, key_klass_list)
        # key_klass_list =
        #   [ { key: 'NAMESPACE:attr_key', klass: class },...]
        # NOTICE: WITHOUT network type checking
        # empty attribute (default) to calculate diff
        @attribute = AttributeBase.new([], {}, '_empty_attr_')
        key_klass_list.each do |list|
          next unless data.key?(list[:key])

          @attribute = list[:klass].new(data[list[:key]], list[:key])
        end
      end

      # @param [Hash] data RFC8345 data
      # @param [String] key supports key in the data
      # @param [Class] klass Class of the support
      # @return [void]
      def setup_supports(data, key, klass)
        @supports = []
        return unless data.key?(key)

        @supports = data[key].map do |support|
          klass.new(support)
        end
      end

      # @param [Hash] data RFC8345 data (RFC8345 + diff-state)
      # @return [void]
      def setup_diff_state(data)
        ds_key = '_diff_state_'
        return unless data[ds_key]

        @diff_state = DiffState.new(
          forward: data[ds_key]['forward']&.intern,
          backward: data[ds_key]['backward']&.intern,
          pair: data[ds_key]['pair'],
          diff_data: data[ds_key]['diff_data'] || nil
        )
      end

      private

      # @return [String] Path string
      def make_path
        [@parent_path, @name].join('__')
      end
    end
  end
end
