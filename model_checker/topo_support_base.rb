module TopoChecker
  # Base class for supporting object reference
  class SupportingRefBase
    attr_accessor :diff_state, :path

    def initialize(ref_key, refs = [])
      @ref_key = ref_key
      @refs = refs
      @diff_state = DiffState.new() # empty state
      @path = 'attribute' # TODO: dummy for #to_data
    end

    def to_s
      "#{@ref_key}:#{ref_path}"
    end

    def to_data
      data = {}
      @refs.each do |r|
        data[r] = send(r) # TODO: key mapping
      end
      data['_diff_state_'] = @diff_state.to_data unless @diff_state.empty?
      data
    end

    def ref_path
      sent_ref_list.join('/')
    end

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      @refs.inject(true) do |result, r|
        result && send(r) == other.send(r)
      end
    end

    def -(other) ## TODO
      changed_attrs = []
      @refs.each do |attr|
        if send(attr) != other.send(attr)
          changed_attrs.push(attr: attr, value: other.send(attr))
        end
      end
      changed_attrs
    end

    private

    def sent_ref_list
      @refs.map { |r| send(r) }
    end
  end
end
