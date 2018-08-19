module TopoChecker
  # Termination point reference
  class TpRef
    attr_reader :node_ref, :tp_ref

    def initialize(data, parent_path)
      @parent_path = parent_path
      @node_ref = data['source-node'] || data['dest-node']
      @tp_ref = data['source-tp'] || data['dest-tp']
    end

    def ==(other)
      @node_ref == other.node_ref && @tp_ref == other.tp_ref
    end

    def to_s
      "tp_ref:#{@node_ref}/#{tp_ref}"
    end

    def ref_path
      [@parent_path, @node_ref, @tp_ref].join('/')
    end
  end

  # Supporting link for topology link data
  class SupportingLink
    attr_reader :network_ref, :link_ref
    def initialize(data)
      @network_ref = data['network-ref']
      @link_ref = data['link-ref']
    end

    def eql?(other)
      @network_ref == other.network_ref && @link_ref == other.link_ref
    end

    def -(other)
      changed_attrs = []
      %i[network_ref link_ref].each do |attr|
        if send(attr) != other.send(attr)
          changed_attrs.push(attr: attr, value: other.send(attr))
        end
      end
      changed_attrs
    end

    def to_s
      "link_ref:#{@network_ref}/#{@link_ref}"
    end
  end
end
