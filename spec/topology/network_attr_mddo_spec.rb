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
end
