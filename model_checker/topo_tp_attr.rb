require_relative 'topo_attr_base'

module TopoChecker
  # Port VLAN ID & Name, for L2 attribute
  class L2VlanIdName < AttributeBase
    ATTRS = %i[id name].freeze
    attr_accessor(*ATTRS)

    def initialize(data)
      super(ATTRS, [:id])
      @id = data['vlan-id'] || 0
      @name = data['vlan-name'] || ''
    end

    def to_s
      "VLAN: #{@id},#{@name}"
    end
  end

  # attribute for L2 termination point
  class L2TPAttribute < AttributeBase
    ATTRS = %i[descr max_frame_size mac_addr eth_encap
               port_vlan_id vlan_id_names tp_state].freeze
    attr_accessor(*ATTRS)

    def initialize(data)
      super(ATTRS, %i[max_frame_size tp_state])
      @descr = data['description'] || ''
      @max_frame_size = data['maximum-frame-size'] || 1500
      @mac_addr = data['mac-address'] || ''
      @eth_encap = data['eth-encapsulation'] || ''
      @port_vlan_id = setup_port_vlan_id(data)
      @tp_state = data['tp-state'] || 'in-use'
    end

    def to_s
      "attribute: #{@descr}" # TODO
    end

    private

    def setup_port_vlan_id(data)
      if data['port-vlan-id'] && !data['port-vlan-id']
        data['port-vlan-id'].map { |p| L2VlanIdName.new(p) }
      else
        []
      end
    end
  end

  # attribute for L3 termination point
  class L3TPAttribute < AttributeBase
    ATTRS = [:ip_addrs].freeze
    attr_accessor(*ATTRS)

    def initialize(data)
      super(ATTRS)
      @ip_addrs = data['ip-address'] || []
    end

    def to_s
      "attribute: #{@ip_addrs}"
    end
  end
end
