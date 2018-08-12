module TopoChecker
  # Termination point for topology data
  class TerminationPoint
    attr_reader :name, :path, :supporting_termination_points, :ref_count

    # Supporting termination point for topology termination point
    class SupportingTerminationPoint
      attr_reader :network_ref, :node_ref, :tp_ref

      def initialize(data)
        @network_ref = data['network-ref']
        @node_ref = data['node-ref']
        @tp_ref = data['tp-ref']
      end

      def to_s
        "tp_ref:#{@network_ref}/#{@node_ref}/#{@tp_ref}"
      end

      def ref_path
        [@network_ref, @node_ref, @tp_ref].join('/')
      end
    end

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

    def ref_count_up
      @ref_count += 1
    end

    def irregular_ref_count?
      @ref_count.zero? || @ref_count.odd? || @ref_count >= 4
    end
  end
end
