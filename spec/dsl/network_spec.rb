# frozen_string_literal: true

RSpec.describe 'network dsl', :dsl, :network do
  before do
    @nws = Netomox::DSL::Networks.new

    @link_key = "#{Netomox::NS_TOPO}:link"
    @tp_key = "#{Netomox::NS_TOPO}:termination-point"
    @l2nw_type = { Netomox::NWTYPE_L2 => {} }
    @l3nw_type = { Netomox::NWTYPE_L3 => {} }
    @l2attr_key = "#{Netomox::NS_L2NW}:l2-network-attributes"
    @l3attr_key = "#{Netomox::NS_L3NW}:l3-topology-attributes"
    @nw_data = {
      'network-id' => 'nwX',
      'network-types' => {},
      'node' => [],
      @link_key => []
    }
  end

  it 'generate single network' do
    nw = Netomox::DSL::Network.new(@nws, 'nwX')
    expect(nw.topo_data).to eq @nw_data
  end

  it 'generate network that has node', :node do
    nw = Netomox::DSL::Network.new(@nws, 'nwX') do
      node 'nodeX'
    end
    nw_data = @nw_data.dup
    nw_data['node'] = [{ 'node-id' => 'nodeX', @tp_key => [] }]
    expect(nw.topo_data).to eq nw_data
  end

  it 'generate network that has uni-directional link (with supporting-link)' do
    link_spec = %w[nodeX tp1 nodeY tp1]
    nw = Netomox::DSL::Network.new(@nws, 'nwX') do
      link link_spec do
        support %w[nwZ a,b,c,d]
      end
    end
    nw_data = @nw_data.dup
    nw_data[@link_key] = [
      {
        'link-id' => link_spec.join(','),
        'source' => {
          'source-node' => link_spec[0],
          'source-tp' => link_spec[1]
        },
        'destination' => {
          'dest-node' => link_spec[2],
          'dest-tp' => link_spec[3]
        },
        'supporting-link' => [
          {
            'network-ref' => 'nwZ',
            'link-ref' => 'a,b,c,d'
          }
        ]
      }
    ]
    expect(nw.topo_data).to eq nw_data
  end

  it 'generate network that has bi-directional link', :link do
    link_spec = %w[nodeX tp1 nodeY tp1]
    nw = Netomox::DSL::Network.new(@nws, 'nwX') do
      bdlink link_spec
    end
    nw_data = @nw_data.dup
    nw_data[@link_key] = [
      {
        'link-id' => link_spec.join(','),
        'source' => {
          'source-node' => link_spec[0],
          'source-tp' => link_spec[1]
        },
        'destination' => {
          'dest-node' => link_spec[2],
          'dest-tp' => link_spec[3]
        }
      },
      {
        'link-id' => link_spec[2, 2].concat(link_spec[0, 2]).join(','),
        'source' => {
          'source-node' => link_spec[2],
          'source-tp' => link_spec[3]
        },
        'destination' => {
          'dest-node' => link_spec[0],
          'dest-tp' => link_spec[1]
        }
      }
    ]
    expect(nw.topo_data).to eq nw_data
  end

  it 'generate network that has supporting-network', :support do
    nw = Netomox::DSL::Network.new(@nws, 'nwX') do
      support 'nw1'
    end
    nw_data = @nw_data.dup
    nw_data['supporting-network'] = [{ 'network-ref' => 'nw1' }]
    expect(nw.topo_data).to eq nw_data
  end

  it 'generate network that has L2 attribute', :attr, :l2attr do
    nw = Netomox::DSL::Network.new(@nws, 'nwX') do
      type Netomox::NWTYPE_L2
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
    nw = Netomox::DSL::Network.new(@nws, 'nwX') do
      type Netomox::NWTYPE_L3
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

  it 'has duplicated supporting-network' do
    result = capture do
      Netomox::DSL::Network.new(@nws, 'nwX') do
        support 'nwY'
        support 'nwY' # duplicated
      end
    end
    expect(result[:stderr].chomp!).to eq 'Duplicated support definition:nwY in networks__nwX'
  end
end
