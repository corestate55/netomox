# frozen_string_literal: true

RSpec.describe 'termination point dsl', :dsl, :tp do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'test-L1' do
        type Netomox::NWTYPE_MDDO_L1
        node 'l1node'
      end
      network 'test-L2' do
        type Netomox::NWTYPE_MDDO_L2
        node 'l2node'
      end
      network 'test-L3' do
        type Netomox::NWTYPE_MDDO_L3
        node 'l3node'
      end
      network 'test-ospf-area0' do
        type Netomox::NWTYPE_MDDO_OSPF_AREA
        node 'ospf_node'
      end
    end
    @l1node = nws.network('test-L1').node('l1node')
    @l2node = nws.network('test-L2').node('l2node')
    @l3node = nws.network('test-L3').node('l3node')
    @ospf_node = nws.network('test-ospf-area0').node('ospf_node')

    @l1attr_key = "#{Netomox::NS_MDDO}:l1-termination-point-attributes"
    @l2attr_key = "#{Netomox::NS_MDDO}:l2-termination-point-attributes"
    @l3attr_key = "#{Netomox::NS_MDDO}:l3-termination-point-attributes"
    @ospf_attr_key = "#{Netomox::NS_MDDO}:ospf-area-termination-point-attributes"
  end

  it 'generate term-point that has L1 attribute', :attr, :l1attr do
    tp_attr = { description: 'tp descr', flags: %w[foo bar] }
    tp = Netomox::DSL::TermPoint.new(@l1node, 'tpX') do
      attribute(tp_attr)
    end
    tp_data = {
      'tp-id' => 'tpX',
      @l1attr_key => {
        'description' => 'tp descr',
        'flag' => %w[foo bar]
      }
    }
    expect(tp.topo_data).to eq tp_data
  end

  it 'generate term-point that has L2 attribute', :attr, :l2attr do
    tp_attr = { description: 'tp descr', encapsulation: 'dot1q', switchport_mode: 'trunk', flags: %w[foo bar] }
    tp = Netomox::DSL::TermPoint.new(@l2node, 'tpX') do
      attribute(tp_attr)
    end
    tp_data = {
      'tp-id' => 'tpX',
      @l2attr_key => {
        'description' => 'tp descr',
        'encapsulation' => 'dot1q',
        'switchport-mode' => 'trunk',
        'flag' => %w[foo bar]
      }
    }
    expect(tp.topo_data).to eq tp_data
  end

  it 'generate term-point that has L3 attribute', :attr, :l3attr do
    tp_attr = { description: 'tp descr', ip_addrs: %w[192.168.3.2/24 192.168.3.1/24], flags: %w[foo bar] }
    tp = Netomox::DSL::TermPoint.new(@l3node, 'tpX') do
      attribute(tp_attr)
    end
    tp_data = {
      'tp-id' => 'tpX',
      @l3attr_key => {
        'description' => 'tp descr',
        'ip-address' => %w[192.168.3.2/24 192.168.3.1/24],
        'flag' => %w[foo bar]
      }
    }
    expect(tp.topo_data).to eq tp_data
  end

  it 'generate term-point that has default ospf-area attribute', :attr, :ospf_attr do
    tp = Netomox::DSL::TermPoint.new(@ospf_node, 'tpX') do
      attribute({})
    end
    tp_data = {
      'tp-id' => 'tpX',
      @ospf_attr_key => {
        'network-type' => '',
        'priority' => 10,
        'metric' => 1,
        'passive' => false,
        'timer' => {
          'hello-interval' => 10,
          'dead-interval' => 40,
          'retransmission-interval' => 5
        },
        'neighbor' => [],
        'area' => -1
      }
    }
    expect(tp.topo_data).to eq tp_data
  end

  # rubocop:disable RSpec/ExampleLength
  it 'generate term-point that has ospf-area attribute', :attr, :ospf_attr do
    tp_attr = {
      network_type: 'p2p',
      priority: 1,
      metric: 10,
      timer: {
        hello_interval: 5,
        dead_interval: 20,
        retransmission_interval: 2
      },
      neighbors: [{ router_id: '10.0.0.1', ip_addr: '192.168.0.1' }],
      area: 1
    }
    tp = Netomox::DSL::TermPoint.new(@ospf_node, 'tpX') do
      attribute(tp_attr)
    end
    tp_data = {
      'tp-id' => 'tpX',
      @ospf_attr_key => {
        'network-type' => 'p2p',
        'priority' => 1,
        'metric' => 10,
        'passive' => false,
        'timer' => {
          'hello-interval' => 5,
          'dead-interval' => 20,
          'retransmission-interval' => 2
        },
        'neighbor' => [
          {
            'router-id' => '10.0.0.1',
            'ip-address' => '192.168.0.1'
          }
        ],
        'area' => 1
      }
    }
    expect(tp.topo_data).to eq tp_data
  end
  # rubocop:enable RSpec/ExampleLength
end
