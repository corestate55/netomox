module TopoChecker
  # Diff state container
  class DiffState
    attr_accessor :forward, :backward, :pair

    def initialize(forward: nil, backward: nil, pair: nil)
      @forward = forward
      @backward = backward
      @pair = pair
    end

    def detect?
      if %i[added deleted].include?(@forward)
        @forward
      elsif [@forward, @backward].include?(:changed)
        :changed
      else
        :kept
      end
    end

    def to_s
      name = @pair && !@pair.empty? ? @pair.name : ''
      "diff_state: fwd:#{@forward}, bwd:#{@backward}, pair:#{name}"
    end

    def to_data
      {
        forward: @forward,
        backward: @backward,
        pair: @pair.nil? ? '' : @pair.path # TODO
      }
    end

    def empty?
      !(@forward || @backward || @pair)
    end
  end
end
