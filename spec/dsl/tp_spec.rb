RSpec.describe 'termination point dsl', :dsl, :tp do
  before do
    @l2nw_type = {Netomox::DSL::NWTYPE_L2 => {} }
    @l3nw_type = {Netomox::DSL::NWTYPE_L3 => {} }
    attr_key = 'termination-point-attributes'.freeze
    @l2attr_key = "#{Netomox::DSL::NS_L2NW}:l2-#{attr_key}"
    @l3attr_key = "#{Netomox::DSL::NS_L3NW}:l3-#{attr_key}"
  end

  it 'generate single term point' do
    tp = Netomox::DSL::TermPoint.new('tpX', '')
    tp_data = { 'tp-id' => 'tpX' }
    expect(tp.topo_data).to eq tp_data
  end

  it 'generate term point that has supporting-tp', :support do
    tp = Netomox::DSL::TermPoint.new('tpX', '') do
      support %w[nw1 node1 tp1]
    end
    tp_data = {
      'tp-id' => 'tpX',
      'supporting-termination-point' => [
        {
          'network-ref' => 'nw1',
          'node-ref' => 'node1',
          'tp-ref' => 'tp1'
        }
      ]
    }
    expect(tp.topo_data).to eq tp_data
  end

  it 'generate term point that has L2 attribute', :attr, :l2attr do
    vlan_a = { id: 10, name: 'Seg.A' }
    vlan_b = { id: 20, name: 'Seg.B' }
    access_vlan_a = {
      port_vlan_id: 10,
      vlan_id_names: [vlan_a, vlan_b]
    }

    tp = Netomox::DSL::TermPoint.new('tpX', @l2nw_type) do
      attribute(access_vlan_a)
    end
    # TODO: default values are OK?
    tp_data = {
      'tp-id' => 'tpX',
      @l2attr_key => {
        'description' => '',
        'maximum-frame-size' => 1500,
        'mac-address' => '',
        'eth-encapsulation' => '',
        'port-vlan-id' => 10,
        'vlan-id-name' => [
          {
            'vlan-id' => 10,
            'vlan-name' => 'Seg.A'
          },
          {
            'vlan-id' => 20,
            'vlan-name' => 'Seg.B'
          }
        ],
        'tp-state' => 'in-use'
      }
    }
    expect(tp.topo_data).to eq tp_data
  end

  it 'generate term point that has L3 attribute', :attr, :l3attr do
    tp_attr = { ip_addrs: %w[192.168.0.1 192.168.1.1] }
    tp = Netomox::DSL::TermPoint.new('tpX', @l3nw_type) do
      attribute(tp_attr)
    end
    tp_data = {
      'tp-id' => 'tpX',
      @l3attr_key => {
        'ip-address' => %w[192.168.0.1 192.168.1.1]
      }
    }
    expect(tp.topo_data).to eq tp_data
  end
end
