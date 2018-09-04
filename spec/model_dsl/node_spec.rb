require_relative '../spec_helper'

describe 'node dsl' do
  before do
    @tp_key = "#{NWTopoDSL::NS_TOPO}:termination-point"
    @l2nw_type = { NWTopoDSL::NWTYPE_L2 => {} }
    @l3nw_type = { NWTopoDSL::NWTYPE_L3 => {} }
    attr_key = 'node-attributes'.freeze
    @l2attr_key = "#{NWTopoDSL::NS_L2NW}:l2-#{attr_key}"
    @l3attr_key = "#{NWTopoDSL::NS_L3NW}:l3-#{attr_key}"
  end

  it 'generate single node' do
    node = NWTopoDSL::Node.new('nodeX', '')
    node_data = {
      'node-id' => 'nodeX',
      @tp_key => []
    }
    expect(node.topo_data).to eq node_data
  end

  it 'generate node that has supporting-node' do
    node = NWTopoDSL::Node.new('nodeX', '') do
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

  it 'generate node that has term point' do
    node = NWTopoDSL::Node.new('nodeX', '') do
      term_point 'tpX'
    end
    node_data = {
      'node-id' => 'nodeX',
      @tp_key => [{ 'tp-id' => 'tpX' }]
    }
    expect(node.topo_data).to eq node_data
  end

  it 'generate node that has L2 attribute' do
    addrs = %w[192.168.0.1 192.168.1.1]
    node_attr = { name: 'tpX', mgmt_vid: 10, mgmt_addrs: addrs }
    node = NWTopoDSL::Node.new('nodeX', @l2nw_type) do
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

  it 'generate node that has L3 attribute' do
    seg_a_prefix = { prefix: '192.168,10.0/24', metric: 100 }
    seg_b_prefix = { prefix: '192.168.20.0/24', metric: 100 }
    pref = { prefixes: [seg_a_prefix, seg_b_prefix] }
    node = NWTopoDSL::Node.new('nodeX', @l3nw_type) do
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
end
