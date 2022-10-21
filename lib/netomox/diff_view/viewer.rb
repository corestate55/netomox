# frozen_string_literal: true

require 'json'
require 'jsonpath'
require 'hashdiff'
require 'termcolor'
require 'netomox/diff_view/viewer_utils'

module Netomox
  module DiffView
    # rubocop:disable Metrics/ClassLength
    # Topology diff data viewer
    class Viewer
      def to_s
        str = stringify
        @color ? convert_color_code(str) : delete_color_code(str)
      end

      def stringify
        output_strs = stringify_data
        output_strs.flatten!
        output_strs.join("\n")
      end

      private

      def diff_data_type_table(diff_data_type)
        case diff_data_type
        when '+' then 'added'
        when '-' then 'deleted'
        when '~' then 'changed'
        else 'kept'
        end
      end

      # @param [Hash] found_data
      # @param [Array<Array>] diff_data
      # @return [void]
      def copy_diff_state(found_data, diff_data)
        if found_data.key?('_diff_state_')
          found_data['_diff_state_']['diff_data'] = [] unless found_data['_diff_state_'].key?('diff_data')
          found_data['_diff_state_']['diff_data'].push(*diff_data)
        else
          found_data['_diff_state_'] = {
            'forward' => diff_data_type_table(diff_data[0][0]),
            'backward' => nil,
            'pair' => nil,
            'diff_data' => diff_data
          }
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      # @return [Array<Array>]
      def detect_diff_data(dd_list)
        return dd_list if dd_list.length == 1 && dd_list[0][0] != '-'

        # Insert deleted data
        if dd_list.length == 1 && dd_list[0][0] == '-'
          dd = dd_list[0] # alias

          # dd: [(+|-|~), jsonpath, diff-data]
          matches = dd[1].match(/(?<path_key>.+)\[(?<index>\d+)\]/)

          # NOTICE: Error when multiple hierarchy path (foo.bar.baz)
          if matches # array path
            key = matches[:path_key]
            @data[key] = [] if !@data.key?(key) || @data[key].nil?
            @data[key].insert(matches[:index].to_i, dd[2].dup) # duplicate to avoid circular reference
            return dd[2].keys.map { |k| [dd[0], k, dd[2][k], ''] }
          end

          # hash path
          key = dd[1]
          @data[key] = dd[2] if !@data.key?(key) || @data[key].nil?
          return [dd]
        end

        # Diff with object array returns + & - diff_data
        # Hashdiff.diff({ data: [{ a:1, b:2 }]}, { data: [{ a:1, b:3 }]})
        # => [["-", "data[0]", {:a=>1, :b=>2}], ["+", "data[0]", {:a=>1, :b=>3}]]
        if dd_list.length == 2 && dd_list.map { |d| d[0] }.sort == %w[+ -]
          dd_before = dd_list.find { |d| d[0] == '-' }[2]
          dd_after = dd_list.find { |d| d[0] == '+' }[2]
          # Hashdiff.diff => [[(+|-|=), key, data]]
          return Hashdiff.diff(dd_before, dd_after)
        end

        msg = dd_list.empty? ? 'Not found diff-data' : 'Found multiple(>2) diff-data'
        raise StandardError msg
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      def relocation_diff_data
        updated_diff_data = []
        # diff_data : [[ (+|-|~), jsonpath, changed-data,... ], ...]
        diff_data = @diff_state['diff_data'] # alias
        dd_keys = diff_data.map { |d| d[1] }.uniq
        dd_keys.each do |dd_key|
          dd_list = diff_data.find_all { |d| d[1] == dd_key }
          dd_list = detect_diff_data(dd_list)

          # dd_key is jsonpath: for example foo, foo.bar, baz[0], ...
          dd_paths = dd_key.split('.')
          next if dd_paths.empty? # when dd_key is empty or '.'

          # jsonpath of diff_data always returns array has a object: [object]
          dd_path0_data = JsonPath.new(dd_paths[0]).on(@data)[0]
          unless dd_path0_data.is_a?(Hash)
            updated_diff_data.push(*dd_list) # keep diff-data entry for self
            next
          end

          # discard diff-data (move to jsonpath-specified object)
          dd_list.each { |dd| dd[1] = dd_paths.slice(1..).join('.') if dd_paths.length > 1 }
          copy_diff_state(dd_path0_data, dd_list)
        end
        @diff_state['diff_data'] = updated_diff_data
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

      def stringify_data
        case @data
        when Array
          stringify_array
        when Hash
          relocation_diff_data if exist_diff_data?
          stringify_hash
        else
          raise StandardError 'Data is literal (single value)?'
        end
      end

      def stringify_single_value(value, state = nil)
        str = if value.nil? || value == ''
                '""' # empty string (json)
              else
                value
              end
        coloring(str, state)
      end

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

      def pack_bra(bra_type, value, state = nil)
        d_state = state.nil? ? detect_state : state
        (bra1, bra2) = bra_pair(bra_type)
        [
          "#{head_mark(d_state)}#{coloring(bra1, d_state)}",
          value,
          "#{head_mark(d_state)}#{coloring(bra2, d_state)}"
        ]
      end

      def stringify_array
        strs = @data.map { |value| stringify_array_value(value) }
        strs.delete(nil) # delete empty value
        strs.delete('') # delete empty value
        v_str = strs.join(",\n")
        v_state = state_by_stringified_str(v_str)
        pack_bra(:array, v_str, v_state)
      end

      def stringify_hash
        return [] if pass_kept?

        keys = @data.keys
        keys.delete('_diff_state_')
        strs = if keys.empty?
                 [''] # empty string
               else
                 keys.map { |key| stringify_hash_key_value(key, @data[key]) }
               end
        strs.delete(nil) # delete empty value
        pack_bra(:hash, strs.join(",\n"))
      end

      def empty_value?(value)
        # avoid empty list(or hash)
        # and empty-key hash (that has only diff_state)
        value.empty? || (value.is_a?(Hash) \
      && value.key?('_diff_state_') && value.keys.length == 1)
      end

      def allowed_empty?(key)
        key =~ /^supporting-/ || key =~ /-attributes$/
      end

      def state_by_stringified_str(str)
        # return nil means set color with self diff_state
        # string doesn't have any color tags, use color as :kept state
        str.match?(%r{<\w+>.*</\w+>}) ? :changed : :kept
      end

      def hash_key_array_color(array_str)
        case @diff_state['forward']
        when 'added', 'deleted'
          # if determined when forward check (filled)
          @diff_state['forward'].intern
        else
          # set key color belongs to its value(array)
          state_by_stringified_str(array_str)
        end
      end

      def stringify_hash_key_array(key, value)
        return nil if allowed_empty?(key) && empty_value?(value)

        dv = Viewer.new(data: value, indent: @indent_b, print_all: @print_all)
        v_str = dv.stringify
        v_state = hash_key_array_color(v_str)
        "#{head_mark(v_state)}#{@indent_b}#{coloring(key, v_state)}: #{v_str}"
      end

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

      def diff_data_includes_key?(key)
        dd_keys = exist_diff_data? ? @diff_state['diff_data'].map { |dd| dd[1] } : []
        dd_keys.include?(key)
      end

      def stringify_value_with_state(key, value, state, orig_value = nil)
        v_str = stringify_single_value(value, state)
        # append old value if :changed_strict
        v_str += coloring(" ~#{orig_value}", state) if state == :changed_strict && !orig_value.nil?
        "#{head_mark(state)}#{@indent_b}#{coloring(key, state)}: #{v_str}"
      end

      def stringify_value(key, value)
        v_str = stringify_single_value(value)
        "#{head_mark}#{@indent_b}#{coloring(key)}: #{v_str}"
      end

      def stringify_value_with_diff_data(key, value, diff_data)
        # dd : Array [ (+|-|~), key, data...]
        case diff_data[0]
        when '+' then stringify_value_with_state(key, value, :added)
        when '-' then stringify_value_with_state(key, value, :deleted)
        when '~' then stringify_value_with_state(key, value, :changed_strict, diff_data[2])
        else stringify_value(key, value)
        end
      end

      def stringify_hash_key_value(key, value)
        # stringify object recursively with deep indent
        case value
        when Array then stringify_hash_key_array(key, value)
        when Hash then stringify_hash_key_hash(key, value)
        else
          if diff_data_includes_key?(key)
            # dd : Array [ (+|-|~), key, data...]
            dd = @diff_state['diff_data'].find { |d| d[1] == key }
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
