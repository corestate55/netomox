module TopoChecker
  class DiffState
    attr_accessor :forward, :backward, :pair

    def initialize(forward: nil, backward: nil, pair: nil)
      @forward = forward
      @backward = backward
      @pair = pair
    end

    def to_s
      name = @pair && !@pair.empty? ? @pair.name : ''
      "diff_state: fwd:#{@forward}, bwd:#{@backward}, pair:#{name}"
    end
  end

  module TopoDiff
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

    def diff_supports(other)
      diff_list(:supports, other)
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

    def diff_attribute(other)
      result = diff_single_value(@attribute, other.attribute)
      other.diff_state = DiffState.new(forward: result, pair: @attribute)
      other
    end
  end
end
