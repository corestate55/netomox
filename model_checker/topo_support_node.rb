module TopoChecker
  # Supporting node for topology node
  class SupportingNode
    attr_reader :network_ref, :node_ref

    def initialize(data)
      @network_ref = data['network-ref']
      @node_ref = data['node-ref']
    end

    def eql?(other)
      @network_ref == other.network_ref && @node_ref == other.node_ref
    end

    def -(other)
      changed_attrs = []
      [:network_ref, :node_ref].each do |attr|
        if self.send(attr) != other.send(attr)
          changed_attrs.push({ attr: attr, value: other.send(attr) })
        end
      end
      changed_attrs
    end

    def to_s
      "node_ref:#{@network_ref}/#{@node_ref}"
    end

    def ref_path
      [@network_ref, @node_ref].join('/')
    end
  end
end
