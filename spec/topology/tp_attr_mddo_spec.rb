# frozen_string_literal: true

RSpec.describe 'check term-point attribute with Mddo-model' do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'nw1' do
        type Netomox::NWTYPE_MDDO_L1
        node('node1') do
          term_point('eth1') do
            attribute(
              description: 'descr of layer1 node1 eth1',
              flags: %w[layer1 term-point]
            )
          end
        end
      end
      network 'nw2' do
        type Netomox::NWTYPE_MDDO_L2
        node('node1') do
          term_point('eth1') do
            attribute(
              description: 'descr of layer2 node1 eth1',
              encapsulation: 'dot1q',
              switchport_mode: 'trunk',
              flags: %w[layer2 term-point]
            )
          end
        end
      end
      network 'nw3' do
        type Netomox::NWTYPE_MDDO_L3
        node('node1') do
          term_point('eth1') do
            attribute(
              description: 'descr of layer3 node1 eth1',
              ip_addrs: %w[192.168.0.1/24 169.254.0.1],
              flags: %w[layer3 term-point]
            )
          end
        end
      end
      network 'nw_ospf' do
        type Netomox::NWTYPE_MDDO_OSPF_AREA
        node('node1') do
          term_point('eth1') do
            attribute(
              network_type: 'broadcast',
              priority: 2,
              metric: 3,
              passive: false,
              timer: {
                hello_interval: 5,
                dead_interval: 20,
                retransmission_interval: 5
              },
              neighbors: [{ router_id: '10.0.0.1', ip_addr: '192.168.0.1' }],
              area: 1
            )
          end
        end
      end
      network 'nw_bgp_proc' do
        type Netomox::NWTYPE_MDDO_BGP_PROC
        node('node1') do
          term_point('eth1') do
            attribute(
              local_as: 65_531,
              local_ip: '10.0.0.21',
              remote_as: 65_531,
              remote_ip: '10.0.0.22',
              description: 'test-descr',
              confederation: 65_530
            )
          end
        end
      end
      network 'nw_bgp_as' do
        type Netomox::NWTYPE_MDDO_BGP_AS
        node('node1') do
          term_point('eth1') do
            attribute(
              description: 'descr of bgp-as node eth1',
              flags: %w[bgp-as term-point]
            )
          end
        end
      end
    end
    topo_data = nws.topo_data
    @nws = Netomox::Topology::Networks.new(topo_data)
    @default_diff_state = { backward: nil, forward: :kept, pair: '' }
  end

  it 'has MDDO layer1 term-point attribute' do
    attr = @nws.find_network('nw1')&.find_node_by_name('node1')&.find_tp_by_name('eth1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'description' => 'descr of layer1 node1 eth1',
      'flag' => %w[layer1 term-point]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO layer2 term-point attribute' do
    attr = @nws.find_network('nw2')&.find_node_by_name('node1')&.find_tp_by_name('eth1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'description' => 'descr of layer2 node1 eth1',
      'encapsulation' => 'dot1q',
      'switchport-mode' => 'trunk',
      'flag' => %w[layer2 term-point]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO layer3 term-point attribute' do
    attr = @nws.find_network('nw3')&.find_node_by_name('node1')&.find_tp_by_name('eth1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'description' => 'descr of layer3 node1 eth1',
      'ip-address' => %w[192.168.0.1/24 169.254.0.1],
      'flag' => %w[layer3 term-point]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO OSPF term-point attribute' do
    attr = @nws.find_network('nw_ospf')&.find_node_by_name('node1')&.find_tp_by_name('eth1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'network-type' => 'broadcast',
      'priority' => 2,
      'metric' => 3,
      'passive' => false,
      'timer' => {
        'hello-interval' => 5,
        'dead-interval' => 20,
        'retransmission-interval' => 5
      },
      'neighbor' => [
        { 'router-id' => '10.0.0.1', 'ip-address' => '192.168.0.1' }
      ],
      'area' => 1
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO BGP-PROC term-point attribute' do
    attr = @nws.find_network('nw_bgp_proc')&.find_node_by_name('node1')&.find_tp_by_name('eth1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'local-as' => 65_531,
      'local-ip' => '10.0.0.21',
      'remote-as' => 65_531,
      'remote-ip' => '10.0.0.22',
      'description' => 'test-descr',
      'confederation' => 65_530,
      'route-reflector-client' => false,
      'cluster-id' => '',
      'peer-group' => '',
      'import-policy' => [],
      'export-policy' => [],
      'timer' => {
        'connect-retry' => 30,
        'hold-time' => 90,
        'keepalive-interval' => 30,
        'minimum-advertisement-interval' => 30,
        'restart-time' => -1
      }
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO BGP-AS term-point attribute' do
    attr = @nws.find_network('nw_bgp_as')&.find_node_by_name('node1')&.find_tp_by_name('eth1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'description' => 'descr of bgp-as node eth1',
      'flag' => %w[bgp-as term-point]
    }
    expect(attr&.to_data).to eq expected_attr
  end
end
