RSpec.describe 'network dsl', :dsl, :network do
  before do
    @link_key = "#{Netomox::DSL::NS_TOPO}:link"
    @tp_key = "#{Netomox::DSL::NS_TOPO}:termination-point"
    @l2nw_type = {Netomox::DSL::NWTYPE_L2 => {} }
    @l3nw_type = {Netomox::DSL::NWTYPE_L3 => {} }
    @l2attr_key = "#{Netomox::DSL::NS_L2NW}:l2-network-attributes"
    @l3attr_key = "#{Netomox::DSL::NS_L3NW}:l3-topology-attributes"
    @nw_data = {
      'network-id' => 'nwX',
      'network-types' => {},
      'node' => [],
      @link_key => []
    }
  end

  it 'generate single network' do
    nw = Netomox::DSL::Network.new('nwX')
    expect(nw.topo_data).to eq @nw_data
  end

  it 'generate network that has node', :node do
    nw = Netomox::DSL::Network.new('nwX') do
      node 'nodeX'
    end
    nw_data = @nw_data.dup
    nw_data['node'] = [{ 'node-id' => 'nodeX', @tp_key => [] }]
    expect(nw.topo_data).to eq nw_data
  end

  it 'generate network that has bi-directional link', :link do
    link = %w[nodeX tp1 nodeY tp1]
    nw = Netomox::DSL::Network.new('nwX') do
      bdlink link
    end
    nw_data = @nw_data.dup
    nw_data[@link_key] = [
      {
        'link-id' => link.join(','),
        'source' => {
          'source-node' => link[0],
          'source-tp' => link[1]
        },
        'destination' => {
          'dest-node' => link[2],
          'dest-tp' => link[3]
        }
      },
      {
        'link-id' => link[2, 2].concat(link[0, 2]).join(','),
        'source' => {
          'source-node' => link[2],
          'source-tp' => link[3]
        },
        'destination' => {
          'dest-node' => link[0],
          'dest-tp' => link[1]
        }
      }
    ]
    expect(nw.topo_data).to eq nw_data
  end

  it 'generate network that has supporting-network', :support do
    nw = Netomox::DSL::Network.new('nwX') do
      support 'nw1'
    end
    nw_data = @nw_data.dup
    nw_data['supporting-network'] = [{ 'network-ref' => 'nw1' }]
    expect(nw.topo_data).to eq nw_data
  end

  it 'generate network that has L2 attribute', :attr, :l2attr do
    nw = Netomox::DSL::Network.new('nwX') do
      type Netomox::DSL::NWTYPE_L2
      attribute(name: 'layer2', flags: %w[foo bar])
    end
    nw_data = @nw_data.dup
    nw_data['network-types'] = @l2nw_type
    nw_data[@l2attr_key] = {
      'name' => 'layer2',
      'flag' => %w[foo bar]
    }
    expect(nw.topo_data).to eq nw_data
  end

  it 'generate network that has L3 attribute', :attr, :l3attr do
    nw = Netomox::DSL::Network.new('nwX') do
      type Netomox::DSL::NWTYPE_L3
      attribute(name: 'layer3', flags: %w[foo bar])
    end
    nw_data = @nw_data.dup
    nw_data['network-types'] = @l3nw_type
    nw_data[@l3attr_key] = {
      'name' => 'layer3',
      'flag' => %w[foo bar]
    }
    expect(nw.topo_data).to eq nw_data
  end
end
