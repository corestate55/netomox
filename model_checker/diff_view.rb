require 'json'
require 'termcolor'

module TopoChecker
  # Topology diff data viewer
  class DiffView
    def initialize(data)
      @data = case data
              when String then JSON.parse(data)
              else data
              end
      @diff_state = {}
    end

    def to_s
      stringify.gsub!(/:\s+/, ': ').termcolor
    end

    def stringify_array
      strs = @data.map do |value|
        case value
        when Array, Hash then
          dv = DiffView.new(value)
          dv.stringify(@indent_b)
        else
          "#{@indent_b}#{value}"
        end
      end
      strs.join(",\n")
    end

    def stringify_hash
      keys = @data.keys
      keys.delete('_diff_state_')
      "\n" if keys.empty?
      strs = keys.map do |key|
        value = @data[key]
        case value
        when Array, Hash
          dv = DiffView.new(value)
          "#{@indent_b}#{coloring(key)}: #{dv.stringify(@indent_b)}"
        else
          "#{@indent_b}#{coloring(key)}: #{coloring(value)}"
        end
      end
      strs.join(",\n")
    end

    def array_bra(pos = :begin)
      bra = pos == :begin ? '[' : ']'
      "#{@indent_a}#{coloring(bra)}"
    end

    def hash_bra(pos = :begin)
      bra = pos == :begin ? '{' : '}'
      "#{@indent_a}#{coloring(bra)}"
    end

    def stringify(indent = '')
      @indent_a = indent
      @indent_b = indent + '  '
      output_strs = []
      case @data
      when Array then
        output_strs.push(array_bra, stringify_array, array_bra(:end))
      when Hash then
        @diff_state = @data['_diff_state_'] if @data.key?('_diff_state_')
        output_strs.push(hash_bra, stringify_hash, hash_bra(:end))
      end
      output_strs.flatten.join("\n")
    end

    private

    def coloring(str)
      (c_begin, c_end) = color_tags
      "#{c_begin}#{str}#{c_end}"
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

    def color_by_diff_state
      case detect_state
      when :added then :green
      when :deleted then :red
      when :changed then :yellow
      end
      # else nil
    end

    def color_tags
      color = color_by_diff_state
      color.nil? ? ['', ''] : %W[<#{color}> </#{color}>]
    end
  end
end
