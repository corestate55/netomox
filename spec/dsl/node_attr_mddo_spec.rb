# frozen_string_literal: true

RSpec.describe 'node dsl', :dsl, :node, :mddo do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'test-L1' do
        type Netomox::NWTYPE_MDDO_L1
      end
      network 'test-L2' do
        type Netomox::NWTYPE_MDDO_L2
      end
      network 'test-L3' do
        type Netomox::NWTYPE_MDDO_L3
      end
    end
    @l1nw = nws.network('test-L1')
    @l2nw = nws.network('test-L2')
    @l3nw = nws.network('test-L3')

    @tp_key = "#{Netomox::NS_TOPO}:termination-point"
    @l1attr_key = "#{Netomox::NS_MDDO}:l1-node-attributes"
    @l2attr_key = "#{Netomox::NS_MDDO}:l2-node-attributes"
    @l3attr_key = "#{Netomox::NS_MDDO}:l3-node-attributes"
  end

  it 'generate node that has L21attribute', :attr, :l1attr do
    node_attr = { os_type: 'JUNOS', flags: %w[foo bar] }
    node = Netomox::DSL::Node.new(@l1nw, 'nodeX') do
      attribute(node_attr)
    end
    node_data = {
      'node-id' => 'nodeX',
      @tp_key => [],
      @l1attr_key => {
        'os-type' => 'JUNOS',
        'flag' => %w[foo bar]
      }
    }
    expect(node.topo_data).to eq node_data
  end

  it 'generate node that has L2 attribute', :attr, :l2attr do
    node_attr = { name: 'l1nodeX', vlan_id: 10, flags: %w[foo bar] }
    node = Netomox::DSL::Node.new(@l2nw, 'nodeX') do
      attribute(node_attr)
    end
    node_data = {
      'node-id' => 'nodeX',
      @tp_key => [],
      @l2attr_key => {
        'name' => 'l1nodeX',
        'vlan-id' => 10,
        'flag' => %w[foo bar]
      }
    }
    expect(node.topo_data).to eq node_data
  end

  it 'generate node that has L3 attribute', :attr, :l3attr do
    node_attr = {
      node_type: 'segment',
      prefixes: [
        { prefix: '192.168.10.0/24', metric: 10, flags: %w[connected] },
        { prefix: '192.168.20.0/24', metric: 100 }
      ],
      flags: %w[foo bar]
    }
    node = Netomox::DSL::Node.new(@l3nw, 'nodeX') do
      attribute(node_attr)
    end
    node_data = {
      'node-id' => 'nodeX',
      @tp_key => [],
      @l3attr_key => {
        'node-type' => 'segment',
        'prefix' => [
          { 'prefix' => '192.168.10.0/24', 'metric' => 10, 'flag' => %w[connected] },
          { 'prefix' => '192.168.20.0/24', 'metric' => 100, 'flag' => [] }
        ],
        'flag' => %w[foo bar]
      }
    }
    expect(node.topo_data).to eq node_data
  end
end
