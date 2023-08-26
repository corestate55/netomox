# frozen_string_literal: true

RSpec.describe 'check network attribute for MDDO' do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'nw1' do
        type Netomox::NWTYPE_MDDO_L1
        attribute(
          name: 'mddo-layer1-network',
          flags: %w[layer1 aaa bbb]
        )
      end
      network 'nw2' do
        type Netomox::NWTYPE_MDDO_L2
        attribute(
          name: 'mddo-layer2-network',
          flags: %w[layer2 aaa bbb]
        )
      end
      network 'nw3' do
        type Netomox::NWTYPE_MDDO_L3
        attribute(
          name: 'mddo-layer3-network',
          flags: %w[layer3 aaa bbb]
        )
      end
      network 'ospf-area0' do
        type Netomox::NWTYPE_MDDO_OSPF_AREA
        attribute(
          name: 'mddo-ospf-area-network',
          flags: %w[ospf-area0 aaa bbb],
          identifier: 0
        )
      end
      network 'bgp-proc' do
        type Netomox::NWTYPE_MDDO_BGP_PROC
        attribute(
          name: 'mddo-bgp-proc-network',
          flags: %w[bgp-proc aaa bbb]
        )
      end
      network 'bgp-as' do
        type Netomox::NWTYPE_MDDO_BGP_AS
        attribute(
          name: 'mddo-bgp-as-network',
          flags: %w[bgp-as aaa bbb]
        )
      end
    end
    topo_data = nws.topo_data
    @nws = Netomox::Topology::Networks.new(topo_data)
    @default_diff_state = { backward: nil, forward: :kept, pair: '' }
  end

  it 'has MDDO layer1 network attribute' do
    attr = @nws.find_network('nw1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'name' => 'mddo-layer1-network',
      'flag' => %w[layer1 aaa bbb]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO layer2 network attribute' do
    attr = @nws.find_network('nw2')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'name' => 'mddo-layer2-network',
      'flag' => %w[layer2 aaa bbb]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO layer3 network attribute' do
    attr = @nws.find_network('nw3')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'name' => 'mddo-layer3-network',
      'flag' => %w[layer3 aaa bbb]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO ospf-area network attribute' do
    attr = @nws.find_network('ospf-area0')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'name' => 'mddo-ospf-area-network',
      'flag' => %w[ospf-area0 aaa bbb],
      'identifier' => 0
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO bgp-proc network attribute' do
    attr = @nws.find_network('bgp-proc')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'name' => 'mddo-bgp-proc-network',
      'flag' => %w[bgp-proc aaa bbb]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO bgp-as network attribute' do
    attr = @nws.find_network('bgp-as')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'name' => 'mddo-bgp-as-network',
      'flag' => %w[bgp-as aaa bbb]
    }
    expect(attr&.to_data).to eq expected_attr
  end
end
