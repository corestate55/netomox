# frozen_string_literal: true

require 'netomox/diff_view/const'
require 'netomox/diff_view/viewer_diff_state'

module Netomox
  module DiffView
    # Topology diff data viewer (Utility functions)
    class Viewer
      def initialize(data:, indent: ' ', print_all: true, color: true)
        @data = case data
                when String then JSON.parse(data)
                else data
                end
        # @diff_state is used to decide text color, set at first
        @diff_state = nil
        @diff_state = ViewerDiffState.new(@data[K_DS]) if @data.is_a?(Hash) && @data.key?(K_DS)
        @indent_a = indent
        @indent_b = "#{indent}  " # 2-space indent
        @print_all = print_all
        @color = color
      end

      def coloring(str, state = nil)
        # state nil means set color with self diff_state
        (c_begin, c_end) = color_tags(state)
        "#{c_begin}#{str}#{c_end}"
      end

      def head_mark(state = nil)
        d_state = state.nil? ? @diff_state&.detect_state : state
        mark = case d_state
               when :added then H_ADD
               when :deleted then H_DEL
               when :changed then H_CHG
               when :changed_strict then H_CHG_S
               else ' '
               end
        coloring(mark, d_state)
      end

      def pass_kept?
        !@print_all && @diff_state&.detect_state == :kept
      end

      private

      def delete_color_code(str)
        # delete all color tags
        str.gsub!(/<\w+>/, '')
        str.gsub!(%r{</\w+>}, '')
        # clean over-wrapped hash key - hash/array bracket
        str.gsub!(/: [.\-+]?\s+/, ': ') # without tag
        str
      end

      def convert_color_code(str)
        # clean over-wrapped hash key - hash/array bracket
        str.gsub!(%r{: <\w+>[.\-+]</\w+>}, ': ')
        str.gsub!(/: (<\w+>)\s+/, ': \1') # with tag
        str.gsub!(/: [.\-+]?\s+/, ': ') # without tag
        # convert color tag to shell color code
        str.termcolor
      end

      def bra_pair(bra_type)
        case bra_type
        when :array then [array_bra, array_bra(:end)]
        when :hash then [hash_bra, hash_bra(:end)]
        else
          ['', '']
        end
      end

      def array_bra(pos = :begin)
        bra = pos == :begin ? '[' : ']'
        "#{@indent_a}#{bra}"
      end

      def hash_bra(pos = :begin)
        bra = pos == :begin ? '{' : '}'
        "#{@indent_a}#{bra}"
      end

      def color_table(state)
        case state
        when :added then :green
        when :deleted then :red
        when :changed_strict then :yellow
        else '' # no color (including when :changed)
        end
      end

      def color_by_diff_state
        color_table(@diff_state&.detect_state)
      end

      def color_tags(state = nil)
        color = state.nil? ? color_by_diff_state : color_table(state)
        color.empty? ? ['', ''] : %W[<#{color}> </#{color}>]
      end
    end
  end
end
