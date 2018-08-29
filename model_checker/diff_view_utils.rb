module TopoChecker
  # Topology diff data viewer (Utility functions)
  class DiffView
    attr_accessor :print_all

    def initialize(data:, indent: ' ', print_all: true, color: true)
      @data = case data
              when String then JSON.parse(data)
              else data
              end
      @diff_state = {}
      @indent_a = indent
      @indent_b = indent + '  ' # 2-space indent
      @print_all = print_all
      @color = color
    end

    def coloring(str, state = nil)
      # state nil means set color with self diff_state
      (c_begin, c_end) = color_tags(state)
      "#{c_begin}#{str}#{c_end}"
    end

    # rubocop:disable Metrics/MethodLength
    def detect_state
      if @diff_state.empty?
        :changed # TODO: ok?
      elsif @diff_state['forward'] == 'added'
        :added
      elsif @diff_state['forward'] == 'deleted'
        :deleted
      elsif [@diff_state['forward'],
             @diff_state['backward']].include?('changed')
        :changed
      else
        :kept
      end
    end
    # rubocop:enable Metrics/MethodLength

    def head_mark(state = nil)
      d_state = state.nil? ? detect_state : state
      mark = case d_state
             when :added then '+'
             when :deleted then '-'
             when :changed then '.'
             else ' '
             end
      coloring(mark, d_state)
    end

    def pass_kept?
      !@print_all && detect_state == :kept
    end

    private

    def delete_color_code(str)
      # delete all color tags
      str.gsub!(/<\w+>/, '')
      str.gsub!(%r{<\/\w+>}, '')
      # clean over-wrapped hash key - hash/array bracket
      str.gsub!(/: [\.\-\+]?\s+/, ': ') # without tag
    end

    def convert_color_code(str)
      # clean over-wrapped hash key - hash/array bracket
      str.gsub!(%r{: <\w+>[\.\-\+]<\/\w+>}, ': ')
      str.gsub!(/: (<\w+>)\s+/, ': \1') # with tag
      str.gsub!(/:\s+/, ': ') # without tag
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
      when :changed then :yellow
      else '' # no color
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
