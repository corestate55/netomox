require_relative 'topo_const'
require_relative 'topo_support_tp'
require_relative 'topo_tp_attr'

module TopoChecker
  # Termination point for topology data
  class TerminationPoint
    attr_reader :name, :path, :supporting_termination_points,
                :ref_count, :attribute
    alias supports supporting_termination_points

    def initialize(data, parent_path)
      @name = data['tp-id']
      @path = [parent_path, @name].join('/')
      @ref_count = 0
      setup_supports(data)
      setup_attribute(data)
    end

    def eql?(other)
      @name == other.name
    end

    def to_s
      "term_point:#{@name}"
    end

    def -(other)
      diff_supports(other)
      diff_attribute(other)
    end

    def ref_count_up
      @ref_count += 1
    end

    def irregular_ref_count?
      @ref_count.zero? || @ref_count.odd? || @ref_count >= 4
    end

    private

    def diff_attribute(other)
      puts '    - term point attribute'
      result = if @attribute == other.attribute
                 :kept
               elsif @attribute.empty?
                 :added
               elsif other.attribute.empty?
                 :deleted
               else
                 :changed
               end
      puts "      - #{result}: #{@attribute} => #{other.attribute}"
    end

    def diff_supports(other)
      deleted_stps = @supporting_termination_points - other.supports
      added_stps = other.supports - @supporting_termination_points
      kept_stps = @supporting_termination_points & other.supports
      puts '    - supporting term points'
      puts "      - deleted sup-tps: #{deleted_stps.map(&:to_s)}"
      puts "      - added   sup-tps: #{added_stps.map(&:to_s)}"
      puts "      - kept    sup-tps: #{kept_stps.map(&:to_s)}"
    end

    def setup_attribute(data)
      l2tp_attr_key = "#{NS_L2NW}:l2-termination-point-attributes"
      l3tp_attr_key = "#{NS_L3NW}:l3-termination-point-attributes"
      # NOTICE: WITHOUT network type check
      @attribute = if data.key?(l2tp_attr_key)
                     L2TPAttribute.new(data[l2tp_attr_key])
                   elsif data.key?(l3tp_attr_key)
                     L3TPAttribute.new(data[l3tp_attr_key])
                   else
                     {}
                   end
    end

    def setup_supports(data)
      @supporting_termination_points = []
      stp_key = 'supporting-termination-point' # alias
      return unless data.key?(stp_key)
      @supporting_termination_points = data[stp_key].map do |stp|
        SupportingTerminationPoint.new(stp)
      end
    end
  end
end
