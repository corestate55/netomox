module TopoChecker
  # Topology diff data viewer (Utility functions)
  class DiffView
    def initialize(data, indent = '')
      @data = case data
              when String then JSON.parse(data)
              else data
              end
      @diff_state = {}
      @indent_a = indent
      @indent_b = indent + '  ' # 2-space indent
    end

    def coloring(str, state = nil)
      # state nil means set color with self diff_state
      (c_begin, c_end) = color_tags(state)
      "#{c_begin}#{str}#{c_end}"
    end

    private

    def array_bra(pos = :begin)
      bra = pos == :begin ? '[' : ']'
      "#{@indent_a}#{coloring(bra)}"
    end

    def hash_bra(pos = :begin)
      bra = pos == :begin ? '{' : '}'
      "#{@indent_a}#{coloring(bra)}"
    end

    def detect_state
      if @diff_state['forward'] == 'added'
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
