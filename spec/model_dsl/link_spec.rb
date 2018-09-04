require_relative '../spec_helper'

describe 'link dsl', :dsl, :link do
  before do
    @l2nw_type = { NWTopoDSL::NWTYPE_L2 => {} }
    @l3nw_type = { NWTopoDSL::NWTYPE_L3 => {} }
    attr_key = 'link-attributes'.freeze
    @l2attr_key = "#{NWTopoDSL::NS_L2NW}:l2-#{attr_key}"
    @l3attr_key = "#{NWTopoDSL::NS_L3NW}:l3-#{attr_key}"
    @link_spec = %w[nodeX tp1 nodeY tp1]
    @link_data = {
      'link-id' => @link_spec.join(','),
      'source' => {
        'source-node' => @link_spec[0],
        'source-tp' => @link_spec[1]
      },
      'destination' => {
        'dest-node' => @link_spec[2],
        'dest-tp' => @link_spec[3]
      }
    }
  end

  it 'generate single link' do
    link = NWTopoDSL::Link.new(*@link_spec, '')
    expect(link.topo_data).to eq @link_data
  end

  it 'generate link that has supporting-link', :support do
    link = NWTopoDSL::Link.new(*@link_spec, '') do
      support %w[foo a,b,c,d]
    end
    link_data = @link_data.dup
    link_data['supporting-link'] = [
      {
        'network-ref' => 'foo',
        'link-ref' => 'a,b,c,d'
      }
    ]
    expect(link.topo_data).to eq link_data
  end

  it 'generate link that has L2 attribute', :attr, :l2attr do
    link_attr = { name: 'linkX', flags: ['l2_link_flag'] }
    link = NWTopoDSL::Link.new(*@link_spec, @l2nw_type) do
      attribute(link_attr)
    end
    link_data = @link_data.dup
    # TODO: default values are OK?
    link_data[@l2attr_key] = {
      'name' => 'linkX',
      'flag' => ['l2_link_flag'],
      'rate' => nil,
      'delay' => nil,
      'srlg' => ''
    }
    expect(link.topo_data).to eq link_data
  end

  it 'generate link that has L3 attribute', :attr, :l3attr do
    link_attr = { name: 'linkX', flags: [], metric1: 100, metric2: 100 }
    link = NWTopoDSL::Link.new(*@link_spec, @l3nw_type) do
      attribute(link_attr)
    end
    link_data = @link_data.dup
    # TODO: default values are OK?
    link_data[@l3attr_key] = {
      'name' => 'linkX',
      'flag' => [],
      'metric1' => 100,
      'metric2' => 100
    }
    expect(link.topo_data).to eq link_data
  end
end
