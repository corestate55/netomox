require_relative 'topo_diff_state'

module TopoChecker
  # Diff functions for Mix-in
  # NOTICE: who receive this methods? (receiver?)
  # when (a) - (b) => (c)
  module TopoDiff
    def diff_supports(other)
      # receiver of this method will be (a), other will be (b)
      diff_list(:supports, other)
    end

    def diff_attribute(other)
      # receiver of this method will be (a), other will be (b)
      result = diff_single_value(@attribute, other.attribute)
      arg = { forward: result, pair: @attribute }
      other.attribute.diff_state = DiffState.new(arg)
      other.attribute
    end

    def diff_forward_check_of(attr, other)
      # receiver of this method will be (a), other will be (b)
      obj_diff = diff_list(attr, other)
      obj_diff.map do |od|
        if od.diff_state.forward == :kept
          od.diff_state.pair.diff(od)
        else
          od
        end
      end
    end

    def diff_backward_check(attrs)
      # receiver of this method will be (c)
      diff_states = []
      attrs.each do |attr|
        case send(attr)
        when Array then
          next if send(attr).empty? # TODO: OK?
          states = send(attr).map { |d| d.diff_state.forward }
          diff_states.push(states)
        else
          diff_states.push(send(attr).diff_state.forward)
        end
      end
      @diff_state.backward = backward_state_from(diff_states)
    end

    private

    def diff_list(attr, other)
      results = []
      send(attr).each do |lhs|
        rhs = other.send(attr).find { |r| lhs == r }
        if rhs
          # lhs found in rhs -> kept
          rhs.diff_state = DiffState.new(forward: :kept, pair: lhs)
          results.push(rhs)
        else
          # lhs only in self -> deleted
          lhs.diff_state = DiffState.new(forward: :deleted)
          results.push(lhs)
        end
      end
      other.send(attr).each do |rhs|
        next if send(attr).find { |l| rhs == l }
        # rhs only in other -> added
        rhs.diff_state = DiffState.new(forward: :added)
        results.push(rhs)
      end
      results
    end

    def diff_single_value(lhs, rhs)
      if lhs == rhs
        :kept
      elsif lhs.empty?
        :added
      elsif rhs.empty?
        :deleted
      else
        :changed
      end
    end

    def backward_state_from(diff_states)
      if diff_states.flatten.all?(:kept)
        :kept
      else
        :changed
      end
    end
  end
end
