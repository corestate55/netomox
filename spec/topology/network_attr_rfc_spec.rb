# frozen_string_literal: true

RSpec.describe 'check network attribute with RFC' do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'nw1' do
        type Netomox::NWTYPE_L3
        attribute(
          name: 'rfc8346-layer3-network',
          flags: %w[layer3 unicast]
        )
      end
    end
    @topo_data = nws.topo_data
    @default_diff_state = { backward: nil, forward: :kept, pair: '' }
  end

  it 'has rfc8345-based network attribute' do
    nws = Netomox::Topology::Networks.new(@topo_data)
    attr = nws.find_network('nw1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'name' => 'rfc8346-layer3-network',
      'flag' => %w[layer3 unicast]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  # TODO: L2 network attribute, it changed RFC8944
end
