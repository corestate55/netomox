# frozen_string_literal: true

require 'json'
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

      def stringify_data
        case @data
        when Array then
          stringify_array
        when Hash then
          # @diff_state is used to decide text color, set at first
          @diff_state = @data['_diff_state_'] if @data.key?('_diff_state_')
          stringify_hash
        end
      end

      def stringify_single_value(value)
        str = if value.nil? || value == ''
                '""' # empty string (json)
              else
                value
              end
        coloring(str)
      end

      def stringify_array_value(value)
        case value
        when Array, Hash then
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
        value.empty? || value.is_a?(Hash) \
      && value.key?('_diff_state_') && value.keys.length == 1
      end

      def allowed_empty?(key)
        key =~ /^supporting-/ || key =~ /-attributes$/
      end

      def state_by_stringified_str(str)
        # return nil means set color with self diff_state
        # string doesn't have any color tags, use color as :kept state
        str.match?(%r{<\w+>.*<\/\w+>}) ? :changed : :kept
      end

      def hash_key_array_color(array_str)
        case @diff_state['forward']
        when 'added', 'deleted' then
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

      def stringify_hash_key_value(key, value)
        # stringify object recursively with deep indent
        case value
        when Array then stringify_hash_key_array(key, value)
        when Hash then stringify_hash_key_hash(key, value)
        else
          v_str = stringify_single_value(value)
          "#{head_mark}#{@indent_b}#{coloring(key)}: #{v_str}"
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
