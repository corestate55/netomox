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

    # rubocop:disable Metrics/CyclomaticComplexity
    def initialize(data)
      super(ATTRS, %i[max_frame_size port_vlan_id tp_state])
      @descr = data['description'] || ''
      @max_frame_size = data['maximum-frame-size'] || 1500
      @mac_addr = data['mac-address'] || ''
      @eth_encap = data['eth-encapsulation'] || ''
      @port_vlan_id = data['port-vlan-id'] || 0
      @vlan_id_names = setup_vlan_id_names(data)
      @tp_state = data['tp-state'] || 'in-use'
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def to_s
      "attribute: #{@descr}" # TODO
    end

    private

    def setup_vlan_id_names(data)
      key = 'vlan-id-name' # alias
      if data.key?(key) && !data[key].empty?
        data[key].map { |p| L2VlanIdName.new(p) }
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
