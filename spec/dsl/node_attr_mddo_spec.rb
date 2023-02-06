# frozen_string_literal: true

RSpec.describe 'node dsl', :dsl, :mddo, :node do
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
      network 'test-ospf-area0' do
        type Netomox::NWTYPE_MDDO_OSPF_AREA
      end
    end
    @l1nw = nws.network('test-L1')
    @l2nw = nws.network('test-L2')
    @l3nw = nws.network('test-L3')
    @ospf_nw = nws.network('test-ospf-area0')

    @tp_key = "#{Netomox::NS_TOPO}:termination-point"
    @l1attr_key = "#{Netomox::NS_MDDO}:l1-node-attributes"
    @l2attr_key = "#{Netomox::NS_MDDO}:l2-node-attributes"
    @l3attr_key = "#{Netomox::NS_MDDO}:l3-node-attributes"
    @ospf_attr_key = "#{Netomox::NS_MDDO}:ospf-area-node-attributes"
  end

  it 'generate node that has L1 attribute', :attr, :l1attr do
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

  # rubocop:disable RSpec/ExampleLength
  it 'generate node that has L3 attribute', :attr, :l3attr do
    node_attr = {
      node_type: 'segment',
      prefixes: [
        { prefix: '192.168.10.0/24', metric: 10, flags: %w[connected] },
        { prefix: '192.168.20.0/24', metric: 100 }
      ],
      static_routes: [
        # NOTE: w/default value
        { prefix: '0.0.0.0/0', next_hop: '192.168.0.1', description: 'default route' },
        { prefix: '192.168.1.0/24', interface: 'eth1', metric: 20, preference: 30, description: 'test route' }
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
        'static-route' => [
          { 'prefix' => '0.0.0.0/0', 'next-hop' => '192.168.0.1', 'interface' => '',
            'metric' => 10, 'preference' => 1, 'description' => 'default route' },
          { 'prefix' => '192.168.1.0/24', 'next-hop' => '', 'interface' => 'eth1',
            'metric' => 20, 'preference' => 30, 'description' => 'test route' }
        ],
        'flag' => %w[foo bar]
      }
    }
    expect(node.topo_data).to eq node_data
  end
  # rubocop:enable RSpec/ExampleLength

  it 'generate node that has ospf-area attribute', :attr, :ospf_attr do
    node_attr = {
      node_type: 'ospf_proc',
      router_id: '192.0.0.1',
      process_id: '1',
      log_adjacency_change: true,
      redistribute: [
        { protocol: 'static', metric_type: 1 },
        { protocol: 'connected' }
      ]
    }
    node = Netomox::DSL::Node.new(@ospf_nw, 'nodeX') do
      attribute(node_attr)
    end
    node_data = {
      'node-id' => 'nodeX',
      @tp_key => [],
      @ospf_attr_key => {
        'node-type' => 'ospf_proc',
        'router-id' => '192.0.0.1',
        'router-id-source' => 'static',
        'process-id' => '1',
        'log-adjacency-change' => true,
        'redistribute' => [
          { 'protocol' => 'static', 'metric-type' => 1 },
          { 'protocol' => 'connected', 'metric-type' => 2 }
        ]
      }
    }
    expect(node.topo_data).to eq node_data
  end
end
