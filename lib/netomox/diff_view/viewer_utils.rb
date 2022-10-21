# frozen_string_literal: true

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
        @diff_state = exist_diff_state? ? @data['_diff_state_'] : {}
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

      def detect_state
        if @diff_state['forward'] == 'added'
          :added
        elsif @diff_state['forward'] == 'deleted'
          :deleted
        elsif [@diff_state['forward'], @diff_state['backward']].include?('changed') || @diff_state.empty?
          # TODO: ok? if @diff_state.empty? is true case
          :changed
        else
          :kept
        end
      end

      def head_mark(state = nil)
        d_state = state.nil? ? detect_state : state
        mark = case d_state
               when :added then '+'
               when :deleted then '-'
               when :changed then '.'
               when :changed_strict then '~'
               else ' '
               end
        coloring(mark, d_state)
      end

      def pass_kept?
        !@print_all && detect_state == :kept
      end

      private

      def exist_diff_state?
        @data.is_a?(Hash) && @data.key?('_diff_state_') && !@data['_diff_state_'].empty?
      end

      def exist_diff_data?
        exist_diff_state? && @diff_state.key?('diff_data') && !@diff_state['diff_data'].empty?
      end

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
        color_table(detect_state)
      end

      def color_tags(state = nil)
        color = state.nil? ? color_by_diff_state : color_table(state)
        color.empty? ? ['', ''] : %W[<#{color}> </#{color}>]
      end
    end
  end
end
