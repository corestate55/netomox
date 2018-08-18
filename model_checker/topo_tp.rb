require_relative 'topo_support_tp'

module TopoChecker
  # Termination point for topology data
  class TerminationPoint
    attr_reader :name, :path, :supporting_termination_points, :ref_count
    alias_method :supports, :supporting_termination_points

    def initialize(data, parent_path)
      @name = data['tp-id']
      @path = [parent_path, @name].join('/')
      @ref_count = 0

      @supporting_termination_points = []
      stp_key = 'supporting-termination-point' # alias
      return unless data.key?(stp_key)
      @supporting_termination_points = data[stp_key].map do |stp|
        SupportingTerminationPoint.new(stp)
      end
    end

    def eql?(other)
      @name == other.name
    end

    def to_s
      "term_point:#{@name}"
    end

    def -(other)
      deleted_stps = @supporting_termination_points - other.supports
      added_stps = other.supports - @supporting_termination_points
      kept_stps = @supporting_termination_points & other.supports
      puts '    - supporting term points'
      puts "      - deleted sup-tps: #{deleted_stps.map(&:to_s)}"
      puts "      - added   sup-tps: #{added_stps.map(&:to_s)}"
      puts "      - kept    sup-tps: #{kept_stps.map(&:to_s)}"
    end

    def ref_count_up
      @ref_count += 1
    end

    def irregular_ref_count?
      @ref_count.zero? || @ref_count.odd? || @ref_count >= 4
    end
  end
end
