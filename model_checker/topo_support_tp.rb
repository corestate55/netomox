module TopoChecker
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

    def eql?(other)
      @network_ref == other.network_ref && @node_ref == other.node_ref \
        && @tp_ref == other.tp_ref
    end

    def -(other)
      changed_attrs = []
      %i[network_ref node_ref tp_ref].each do |attr|
        if send(attr) != other.send(attr)
          changed_attrs.push(attr: attr, value: other.send(attr))
        end
      end
      changed_attrs
    end
  end
end
