# frozen_string_literal: true

RSpec.describe 'node dsl', :dsl, :node do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'test-L1'
      network 'test-L2' do
        type Netomox::NWTYPE_L2
      end
      network 'test-L3' do
        type Netomox::NWTYPE_L3
      end
    end
    @l1nw = nws.network('test-L1')
    @l2nw = nws.network('test-L2')
    @l3nw = nws.network('test-L3')

    @tp_key = "#{Netomox::NS_TOPO}:termination-point"
    attr_key = 'node-attributes'
    @l2attr_key = "#{Netomox::NS_L2NW}:l2-#{attr_key}"
    @l3attr_key = "#{Netomox::NS_L3NW}:l3-#{attr_key}"
  end

  it 'generate single node' do
    node = Netomox::DSL::Node.new(@l1nw, 'nodeX')
    node_data = {
      'node-id' => 'nodeX',
      @tp_key => []
    }
    expect(node.topo_data).to eq node_data
  end

  it 'generate node that has supporting-node', :support do
    node = Netomox::DSL::Node.new(@l1nw, 'nodeX') do
      support %w[nw1 node1]
    end
    node_data = {
      'node-id' => 'nodeX',
      @tp_key => [],
      'supporting-node' => [
        {
          'network-ref' => 'nw1',
          'node-ref' => 'node1'
        }
      ]
    }
    expect(node.topo_data).to eq node_data
  end

  it 'generate node that has term point', :tp do
    node = Netomox::DSL::Node.new(@l1nw, 'nodeX') do
      term_point 'tpX'
    end
    node_data = {
      'node-id' => 'nodeX',
      @tp_key => [{ 'tp-id' => 'tpX' }]
    }
    expect(node.topo_data).to eq node_data
  end

  it 'generate node that has L2 attribute', :attr, :l2attr do
    addrs = %w[192.168.0.1 192.168.1.1]
    node_attr = { name: 'tpX', mgmt_vid: 10, mgmt_addrs: addrs }
    node = Netomox::DSL::Node.new(@l2nw, 'nodeX') do
      attribute(node_attr)
    end
    # TODO: default values are OK?
    node_data = {
      'node-id' => 'nodeX',
      @tp_key => [],
      @l2attr_key => {
        'name' => 'tpX',
        'description' => '',
        'management-address' => %w[192.168.0.1 192.168.1.1],
        'sys-mac-address' => '',
        'management-vid' => 10,
        'flag' => []
      }
    }
    expect(node.topo_data).to eq node_data
  end

  it 'generate node that has L3 attribute', :attr, :l3attr do
    seg_a_prefix = { prefix: '192.168,10.0/24', metric: 100 }
    seg_b_prefix = { prefix: '192.168.20.0/24', metric: 100 }
    pref = { prefixes: [seg_a_prefix, seg_b_prefix] }
    node = Netomox::DSL::Node.new(@l3nw, 'nodeX') do
      attribute(pref)
    end
    # TODO: default values are OK?
    node_data = {
      'node-id' => 'nodeX',
      @tp_key => [],
      @l3attr_key => {
        'name' => '',
        'flag' => [],
        'router-id' => [''],
        'prefix' => [
          {
            'prefix' => '192.168,10.0/24',
            'metric' => 100,
            'flag' => []
          },
          {
            'prefix' => '192.168.20.0/24',
            'metric' => 100,
            'flag' => []
          }
        ]
      }
    }
    expect(node.topo_data).to eq node_data
  end

  it 'ignore duplicated supporting-node' do
    node = Netomox::DSL::Node.new(@l1nw, 'nodeX')
    result = capture do
      node.register do
        support %w[nwY nodeY]
        support %w[nwY nodeY] # duplicated
      end
    end
    expect(result[:stderr].chomp!).to eq 'Ignore: Duplicated support definition:nwY__nodeY in networks__test-L1__nodeX'
    expect(node.supports.length).to eq 1
  end
end
