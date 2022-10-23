# frozen_string_literal: true

require 'json'
require 'jsonpath'
require 'hashdiff'
require 'termcolor'
require 'netomox/diff_view/const'
require 'netomox/diff_view/viewer_utils'
require 'netomox/diff_view/viewer_diff_state'

module Netomox
  module DiffView
    # rubocop:disable Metrics/ClassLength
    # Topology diff data viewer
    class Viewer
      def to_s
        str = stringify
        @color ? convert_color_code(str) : delete_color_code(str)
      end

      # @return [String]
      def stringify
        output_strs = stringify_data
        output_strs.flatten!
        output_strs.join("\n")
      end

      private

      # @param [Hash] next_data
      # @param [Array<ViewerDiffElement>] dd_list (one diff-data array)
      # @return [void]
      def copy_diff_state(next_data, dd_list)
        # objectify diff-state in each hierarchy, then it must copy as hash data
        if next_data.key?(K_DS)
          next_data[K_DS][K_DD] = [] unless next_data[K_DS].key?(K_DD)
          next_data[K_DS][K_DD].push(*dd_list.map(&:to_data))
        else
          next_data[K_DS] = {
            K_FWD => dd_list[0].type_symbol.to_s,
            K_BWD => nil,
            K_PAIR => nil,
            K_DD => dd_list.map(&:to_data)
          }
        end
      end

      # @param [String] key
      # @return [Boolean]
      def exist_data?(key)
        !@data.key?(key) || @data[key].nil?
      end

      # rubocop:disable Metrics/AbcSize

      # @param [Array<ViewerDiffElement>] dd_list
      # @return [Array(ViewerDiffElement)] detected diff-data
      #   (always returns one diff-data as array [diff-data])
      def detect_diff_data_len1(dd_list)
        return dd_list unless dd_list[0].type?(:deleted)

        # Insert deleted data
        dd = dd_list[0] # alias

        # NOTICE: Error when multiple hierarchy path (foo.bar.baz)
        path_key, index = dd.path_matches_array
        if path_key && index
          @data[path_key] = [] if exist_data?(path_key)
          @data[path_key].insert(index, dd.dd_before.dup) # duplicate to avoid circular reference
          return dd.dd_before.keys.map do |k|
            ViewerDiffElement.new([dd.type_sign, k, dd.dd_before[k], ''])
          end
        end

        # hash path
        path_key = dd.path
        @data[path_key] = dd.dd_all if exist_data?(path_key)
        [dd]
      end
      # rubocop:enable Metrics/AbcSize

      # @param [Array<ViewerDiffElement>] dd_list
      # @return [Boolean]
      def add_delete_dd_pair?(dd_list)
        dd_list.length == 2 && dd_list.map(&:type_symbol).sort == %i[added deleted]
      end

      # Diff with object array returns :added & :::deleted diff_data pair
      #   Hashdiff.diff({ data: [{ a:1, b:2 }]}, { data: [{ a:1, b:3 }]})
      #   => [["-", "data[0]", {:a=>1, :b=>2}], ["+", "data[0]", {:a=>1, :b=>3}]]
      # @param [Array<ViewerDiffElement>] dd_list
      # @return [Array(ViewerDiffElement)]
      def detect_diff_data_len2(dd_list)
        dd_deleted = dd_list.find { |d| d.type?(:deleted) }
        dd_added = dd_list.find { |d| d.type?(:added) }
        # Hashdiff.diff => [[(+|-|=), key, data]]
        new_dd = Hashdiff.diff(dd_deleted.dd_before, dd_added.dd_after)
        new_dd.map { |d| ViewerDiffElement.new(d) }
      end

      # @param [String] dd_path jsonpath of diff-data
      # @return [Array<ViewerDiffElement>] found diff-data
      def detect_diff_data(dd_path)
        dd_list = @diff_state.find_all_dd_by_path(dd_path)
        return detect_diff_data_len1(dd_list) if dd_list.length == 1
        return detect_diff_data_len2(dd_list) if add_delete_dd_pair?(dd_list)

        # unknown pattern
        msg = dd_list.empty? ? 'Not found diff-data' : "Found multiple(>2) diff-data: #{dd_list}"
        raise StandardError, msg
      end

      # @param [String] jsonpath
      # @return [Object]
      def data_by_jsonpath(jsonpath)
        # jsonpath of diff_data always returns array has a object: [object]
        JsonPath.new(jsonpath).on(@data)[0]
      end

      # @return [void]
      def relocation_diff_data
        self_dd_list = []
        dd_paths = @diff_state.dd_paths.uniq
        dd_paths.each do |dd_path|
          dd_list = detect_diff_data(dd_path)

          # dd_key is jsonpath: for example foo, foo.bar, baz[0]
          dd_path_elements = dd_path.split('.')
          # when dd_key is empty or '.', ignore it
          # because attribute is always hash (always exist key if appears diff)
          next if dd_path_elements.empty?

          # Is the found diff-data for itself or child-attribute?
          child_data = data_by_jsonpath(dd_path_elements[0])
          unless child_data.is_a?(Hash)
            self_dd_list.push(*dd_list) # save diff-data entry for self
            next
          end

          # relocate diff-data to child-attribute and discard it for self
          # (move the diff-data to jsonpath-specified object)
          dd_list.each(&:rewrite_path_to_child!)
          copy_diff_state(child_data, dd_list)
        end
        @diff_state.diff_data = self_dd_list
      end

      # @return [Array<String>]
      def stringify_data
        case @data
        when Array
          stringify_array
        when Hash
          relocation_diff_data if @diff_state&.exist_diff_data?
          stringify_hash
        else
          raise StandardError 'Data is literal (single value)?'
        end
      end

      # @param [nil, String, Numeric] value
      # @@param [Symbol] state diff-state
      def stringify_single_value(value, state = nil)
        str = if value.nil? || value == ''
                '""' # empty string (json)
              else
                value
              end
        coloring(str, state)
      end

      # @param [Object] value
      # @return [String, Array<String>]
      def stringify_array_value(value)
        case value
        when Array, Hash
          dv = Viewer.new(data: value, indent: @indent_b, print_all: @print_all)
          # stringify array element recursively with deep indent
          dv.stringify
        else
          "#{@indent_b}#{stringify_single_value(value)}"
        end
      end

      # @param [Symbol] bra_type  type: [:array, :hash]
      # @param [String] value
      # @param [Symbol] state
      # @return [Array<String>]
      def pack_bra(bra_type, value, state = nil)
        d_state = state.nil? ? @diff_state&.detect_state : state
        (bra1, bra2) = bra_pair(bra_type)
        [
          "#{head_mark(d_state)}#{coloring(bra1, d_state)}",
          value,
          "#{head_mark(d_state)}#{coloring(bra2, d_state)}"
        ]
      end

      # @return [Array<String>]
      def stringify_array
        strs = @data.map { |value| stringify_array_value(value) }
        strs.delete(nil) # delete empty value
        strs.delete('') # delete empty value
        v_str = strs.join(",\n")
        v_state = state_by_stringified_str(v_str)
        pack_bra(:array, v_str, v_state)
      end

      # @return [Array<String>]
      def stringify_hash
        return [] if pass_kept?

        keys = @data.keys
        keys.delete(K_DS) # delete diff-state
        strs = if keys.empty?
                 [''] # empty string
               else
                 keys.map { |key| stringify_hash_key_value(key, @data[key]) }
               end
        strs.delete(nil) # delete empty value
        pack_bra(:hash, strs.join(",\n"))
      end

      # @param [Array, Hash, String] value
      # @return [Boolean] true if the value is empty list or hash
      def empty_value?(value)
        # avoid empty list(or hash) and empty-key hash (that has only diff_state)
        value.empty? || (value.is_a?(Hash) && value.key?(K_DS) && value.keys.length == 1)
      end

      # @param [String] key
      # @return [Boolean] true if the key is allowed be empty
      def allowed_empty?(key)
        key.match?(/(^supporting-|-attributes$)/)
      end

      # @param [String] str stringified string (including coloring xml tag)
      # @return [Symbol] state
      def state_by_stringified_str(str)
        # return nil means set color with self diff_state
        # string doesn't have any color tags, use color as :kept state
        str.match?(%r{<\w+>.*</\w+>}) ? :changed : :kept
      end

      # @param [String] array_str Stringified array
      # @return [Symbol] state
      def hash_key_array_color(array_str)
        case @diff_state.forward
        when :added, :deleted
          # if determined when forward check (filled)
          @diff_state.forward
        else
          # set key color belongs to its value(array)
          state_by_stringified_str(array_str)
        end
      end

      # @param [String] key Data key
      # @param [Array] value Data
      # @return [String, nil]
      def stringify_hash_key_array(key, value)
        return nil if allowed_empty?(key) && empty_value?(value)

        dv = Viewer.new(data: value, indent: @indent_b, print_all: @print_all)
        v_str = dv.stringify
        v_state = hash_key_array_color(v_str)
        "#{head_mark(v_state)}#{@indent_b}#{coloring(key, v_state)}: #{v_str}"
      end

      # @param [String] key Data key
      # @param [Hash] value Data
      # @return [String, nil]
      def stringify_hash_key_hash(key, value)
        return nil if allowed_empty?(key) && empty_value?(value)

        dv = Viewer.new(data: value, indent: @indent_b, print_all: @print_all)
        # set key color belongs to its value(Hash)
        # decide dv diff_state before make key str
        # NOTICE: detect_state (diff_state) defined AFTER stringify
        v_str = dv.stringify
        return nil if dv.pass_kept?

        "#{dv.head_mark}#{@indent_b}#{dv.coloring(key)}: #{v_str}"
      end

      # @param [String] key Data key
      # @param [String, Numeric] value Data
      # @param [Symbol] state
      # @param [Object] orig_value
      # @return [String]
      def stringify_value_with_state(key, value, state, orig_value = nil)
        v_str = stringify_single_value(value, state)
        # append old value if :changed_strict
        v_str += coloring(" ~#{orig_value}", state) if state == :changed_strict && !orig_value.nil?
        "#{head_mark(state)}#{@indent_b}#{coloring(key, state)}: #{v_str}"
      end

      # @param [String] key Data key
      # @param [String, Numeric] value Data
      # @return [String]
      def stringify_value(key, value)
        v_str = stringify_single_value(value)
        "#{head_mark}#{@indent_b}#{coloring(key)}: #{v_str}"
      end

      # @param [String] key Data key
      # @param [String, Numeric] value Data
      # @param [ViewerDiffElement] diff_data
      # @return [String]
      def stringify_value_with_diff_data(key, value, diff_data)
        case diff_data.type_symbol
        when :added then stringify_value_with_state(key, value, :added)
        when :deleted then stringify_value_with_state(key, value, :deleted)
        when :changed then stringify_value_with_state(key, value, :changed_strict, diff_data.dd_before)
        else stringify_value(key, value)
        end
      end

      # @param [String] key Data key
      # @param [Object] value Data
      # @return [String, nil] nil line is ignored (empty line)
      def stringify_hash_key_value(key, value)
        # stringify object recursively with deep indent
        case value
        when Array then stringify_hash_key_array(key, value)
        when Hash then stringify_hash_key_hash(key, value)
        else
          if @diff_state&.dd_paths_include?(key)
            dd = @diff_state&.find_dd_by_path(key)
            stringify_value_with_diff_data(key, value, dd)
          else
            stringify_value(key, value)
          end
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
