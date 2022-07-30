# frozen_string_literal: true

RSpec.describe 'network dsl', :dsl, :network, :mddo do
  before do
    @nws = Netomox::DSL::Networks.new

    @link_key = "#{Netomox::NS_TOPO}:link"
    @tp_key = "#{Netomox::NS_TOPO}:termination-point"

    @l1nw_type = { Netomox::NWTYPE_MDDO_L1 => {} }
    @l2nw_type = { Netomox::NWTYPE_MDDO_L2 => {} }
    @l3nw_type = { Netomox::NWTYPE_MDDO_L3 => {} }
    @ospf_nw_type = { Netomox::NWTYPE_MDDO_OSPF_AREA => {} }

    @l1attr_key = "#{Netomox::NS_MDDO}:l1-network-attributes"
    @l2attr_key = "#{Netomox::NS_MDDO}:l2-network-attributes"
    @l3attr_key = "#{Netomox::NS_MDDO}:l3-network-attributes"
    @ospf_attr_key = "#{Netomox::NS_MDDO}:ospf-area-network-attributes"
  end

  it 'generate network that has L1 attribute', :attr, :l1attr do
    nw = Netomox::DSL::Network.new(@nws, 'nwX') do
      type Netomox::NWTYPE_MDDO_L1
      attribute(name: 'layer1', flags: %w[foo bar])
    end
    nw_data = {
      'network-id' => 'nwX',
      'network-types' => @l1nw_type,
      'node' => [],
      @link_key => [],
      @l1attr_key => {
        'name' => 'layer1',
        'flag' => %w[foo bar]
      }
    }
    expect(nw.topo_data).to eq nw_data
  end

  it 'generate network that has L2 attribute', :attr, :l2attr do
    nw = Netomox::DSL::Network.new(@nws, 'nwX') do
      type Netomox::NWTYPE_MDDO_L2
      attribute(name: 'layer2', flags: %w[foo bar])
    end
    nw_data = {
      'network-id' => 'nwX',
      'network-types' => @l2nw_type,
      'node' => [],
      @link_key => [],
      @l2attr_key => {
        'name' => 'layer2',
        'flag' => %w[foo bar]
      }
    }
    expect(nw.topo_data).to eq nw_data
  end

  it 'generate network that has L3 attribute', :attr, :l3attr do
    nw = Netomox::DSL::Network.new(@nws, 'nwX') do
      type Netomox::NWTYPE_MDDO_L3
      attribute(name: 'layer3', flags: %w[foo bar])
    end
    nw_data = {
      'network-id' => 'nwX',
      'network-types' => @l3nw_type,
      'node' => [],
      @link_key => [],
      @l3attr_key => {
        'name' => 'layer3',
        'flag' => %w[foo bar]
      }
    }
    expect(nw.topo_data).to eq nw_data
  end

  it 'generate network that has ospf-area attribute', :attr, :ospf_attr do
    nw = Netomox::DSL::Network.new(@nws, 'nwX') do
      type Netomox::NWTYPE_MDDO_OSPF_AREA
      attribute(name: 'area0', identifier: '0.0.0.0', flags: %w[foo bar])
    end
    nw_data = {
      'network-id' => 'nwX',
      'network-types' => @ospf_nw_type,
      'node' => [],
      @link_key => [],
      @ospf_attr_key => {
        'name' => 'area0',
        'identifier' => '0.0.0.0',
        'flag' => %w[foo bar]
      }
    }
    expect(nw.topo_data).to eq nw_data
  end
end
