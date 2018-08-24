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

    def stringify(indent = '')
      @indent_a = indent
      @indent_b = indent + '  ' # 2-space indent
      output_strs = stringify_data
      output_strs.flatten.join("\n")
    end

    private

    def stringify_data
      case @data
      when Array then
        [array_bra, stringify_array, array_bra(:end)]
      when Hash then
        # @diff_state is used to decide text color, set at first
        @diff_state = @data['_diff_state_'] if @data.key?('_diff_state_')
        [hash_bra, stringify_hash, hash_bra(:end)]
      end
    end

    def stringify_value(value)
      str = value.nil? || value == '' ? '""' : value
      coloring(str)
    end

    def stringify_array_value(value)
      case value
      when Array, Hash then
        dv = DiffView.new(value)
        # stringify array element recursively with deep indent
        dv.stringify(@indent_b)
      else
        "#{@indent_b}#{stringify_value(value)}"
      end
    end

    def stringify_array
      strs = @data.map do |value|
        stringify_array_value(value)
      end
      strs.join(",\n")
    end

    def stringify_hash_key_value(key, value)
      case value
      when Array, Hash
        dv = DiffView.new(value)
        # stringify ofject as hash value recursively with deep indent
        "#{@indent_b}#{coloring(key)}: #{dv.stringify(@indent_b)}"
      else
        "#{@indent_b}#{coloring(key)}: #{stringify_value(value)}"
      end
    end

    def stringify_hash
      keys = @data.keys
      keys.delete('_diff_state_')
      return '' if keys.empty?
      strs = keys.map do |key|
        stringify_hash_key_value(key, @data[key])
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
      else '' # no color
      end
    end

    def color_tags
      color = color_by_diff_state
      color.empty? ? ['', ''] : %W[<#{color}> </#{color}>]
    end
  end
end
