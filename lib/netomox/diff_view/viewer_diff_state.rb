# frozen_string_literal: true

require 'netomox/diff_view/const'

module Netomox
  module DiffView
    # Element of diff-data
    class ViewerDiffElement
      # @!attribute [r] type_sign
      #   @return [String] +, -, ~
      # @!attribute [r] type_symbol
      #   @return [Symbol]
      # @!attribute [r] path
      #   @return [String] jsonpath of diff-data
      # @!attribute [r] dd_all
      #   @return [Array<Object>] diff-data
      # @!attribute [r] dd_before
      #   @return [Object] diff-data (before changed)
      # @!attribute [r] dd_after
      #   @return [Object] diff-data (after changed)
      attr_reader :type_sign, :type_symbol, :path, :dd_all, :dd_before, :dd_after

      # @param [Array] dd_element Array: [ (+|-|~), jsonpath, changed-data [, changed-data] ]
      def initialize(dd_element)
        @type_sign = dd_element[0] # +, -, ~
        @type_symbol = diff_data_type_table
        @path = dd_element[1]
        # changed: [before, after], added/deleted: [value]
        @dd_all = dd_element.slice(2..)
        @dd_before, @dd_after = select_dd_body
      end

      # @param [Symbol] type_symbol
      # @return [Boolean] true if diff_data type-symbol equals specified it
      def type?(type_symbol)
        @type_symbol == type_symbol
      end

      # @return [Array<String, nil>] [path, index] if the jsonpath matches array-string (ex. foo[0])
      def path_matches_array
        m = @path.match(/(?<path_key>.+)\[(?<index>\d+)\]/)
        m.nil? ? [nil, nil] : [m[:path_key], m[:index].to_i]
      end

      # @return [Array<String>] elements of jsonpath
      def path_elements
        @path.split('.')
      end

      # @return [void]
      def rewrite_path_to_child!
        list = path_elements
        # discard head element
        @path = list.slice(1..).join('.') if list.length > 1
      end

      # @return [Array]
      def to_data
        [@type_sign, @path, *@dd_all]
      end

      # @return [String]
      def to_s
        to_data.to_s
      end

      private

      # @return [Array<nil, Object>]
      def select_dd_body
        case @type_symbol
        when :changed then @dd_all
        when :deleted then [@dd_all[0], nil]
        when :added then [nil, @dd_all[0]]
        else [nil, nil]
        end
      end

      # @return [Symbol]
      def diff_data_type_table
        case @type_sign
        when H_ADD then :added
        when H_DEL then :deleted
        when H_CHG_S then :changed
        else :kept
        end
      end
    end

    # diff-state
    class ViewerDiffState
      # @!attribute [r] forward
      #   @return [Symbol, nil]
      # @!attribute [r] backward
      #   @return [Symbol, nil]
      # @!attribute [r] path
      #   @return [String, nil]
      # @!attribute [rw] diff_data
      #   @return [Array<ViewerDiffElement>, nil]
      attr_reader :forward, :backward, :pair
      attr_accessor :diff_data

      # @param [Hash] ds_hash
      def initialize(ds_hash)
        # NOTICE: nil-able
        @ds_hash = ds_hash
        @forward, @backward, @pair = if ds_hash.nil?
                                       [:kept, nil, nil]
                                     else
                                       [ds_hash[K_FWD]&.to_sym, ds_hash[K_BWD]&.to_sym, ds_hash[K_PAIR]]
                                     end

        # diff_data : [[ (+|-|~), jsonpath, changed-data,... ], ...]
        @diff_data = []
        @diff_data = ds_hash[K_DD].map { |dd| ViewerDiffElement.new(dd) } if ds_hash&.key?(K_DD)
      end

      # @return [Boolean] true if the diff-state exists
      def exist?
        !empty?
      end

      # @return [Boolean] true if the diff-state owns diff-data
      def exist_diff_data?
        exist? && !@diff_data.empty?
      end

      # @return [Boolean] true if the diff-state is empty
      def empty?
        !nil? && @ds_hash.empty?
      end

      # @return [Boolean] true if the diff-state is nil
      def nil?
        @ds_hash.nil?
      end

      # @return [Symbol] final diff-state
      def detect_state
        if @forward == :added
          :added
        elsif @forward == :deleted
          :deleted
        elsif [@forward, @backward].include?(:changed) || empty?
          # TODO: ok? if @diff_state.empty? is true case
          :changed
        else
          :kept
        end
      end

      # @return [Hash]
      def to_data
        data = {
          K_FWD => @forward&.to_s,
          K_BWD => @backward&.to_s,
          K_PAIR => @pair
        }
        data[K_DD] = @diff_data.map(&:to_data) if exist_diff_data?
        data
      end

      # @return [Array<String>] List of jsonpath of diff-data
      def dd_paths
        @diff_data.map(&:path)
      end

      # @param [String] path Jsonpath
      # @return [Boolean] true if the jsonpath is included in diff-data jsonpath
      def dd_paths_include?(path)
        dd_paths.include?(path)
      end

      # @param [String] path Jsonpath
      # @return [ViewerDiffElement, nil] Found diff-element
      def find_dd_by_path(path)
        @diff_data.find { |d| d.path == path }
      end

      # @param [String] path Jsonpath
      # @return [Array<ViewerDiffElement>] Found diff-element
      def find_all_dd_by_path(path)
        @diff_data.find_all { |d| d.path == path }
      end
    end
  end
end
