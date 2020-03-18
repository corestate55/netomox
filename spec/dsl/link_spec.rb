# frozen_string_literal: true

RSpec.describe 'link dsl', :dsl, :link do
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

    attr_key = 'link-attributes'
    @l2attr_key = "#{Netomox::NS_L2NW}:l2-#{attr_key}"
    @l3attr_key = "#{Netomox::NS_L3NW}:l3-#{attr_key}"
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
    link = Netomox::DSL::Link.new(@l1nw, *@link_spec)
    expect(link.topo_data).to eq @link_data
  end

  it 'generate link that has supporting-link', :support do
    link = Netomox::DSL::Link.new(@l1nw, *@link_spec) do
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
    link = Netomox::DSL::Link.new(@l2nw, *@link_spec) do
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
    link = Netomox::DSL::Link.new(@l3nw, *@link_spec) do
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

  it 'ignore duplicated supporting-link' do
    link = Netomox::DSL::Link.new(@l1nw, *@link_spec)
    result = capture do
      link.register do
        support %w[nwY a,p1,b,p2]
        support %w[nwY a,p1,b,p2] # duplicated
      end
    end
    expect(result[:stderr].chomp!).to eq 'Ignore: Duplicated support definition:nwY__a,p1,b,p2 in networks__test-L1__nodeX,tp1,nodeY,tp1'
    expect(link.supports.length).to eq 1
  end
end
