module TopoChecker
  # Supporting network for network topology data
  class SupportingNetwork
    attr_reader :network_ref

    def initialize(data)
      @network_ref = data['network-ref']
    end

    def eql?(other)
      @network_ref == other.network_ref
    end

    def -(other)
      changed_attrs = []
      [:network_ref].each do |attr|
        if send(attr) != other.send(attr)
          changed_attrs.push(attr: attr, value: other.send(attr))
        end
      end
      changed_attrs
    end

    def to_s
      "nw_ref:#{@network_ref}"
    end

    def ref_path
      @network_ref
    end
  end
end
