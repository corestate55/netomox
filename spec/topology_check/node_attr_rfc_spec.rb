# frozen_string_literal: true

RSpec.describe 'check node attribute with RFC' do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'nw1' do
        type Netomox::NWTYPE_L3
        node('node1') do
          attribute(
            prefixes: [
              { prefix: '192.168.0.0/24', metric: 1, flags: 'test'},
              { prefix: '192.168.1.0/24', metric: 10, flags: %w[foo bar]}
            ],
            router_id: '192.168.0.1',
            flags: %w[layer3 node],
            name: 'node1'
          )
        end
      end
    end
    topo_data = nws.topo_data
    @nws = Netomox::Topology::Networks.new(topo_data)
    @default_diff_state = { :backward=>nil, :forward=>:kept, :pair=>"" }
  end

  it 'has rfc8345-based node attribute' do
    attr = @nws.find_network('nw1')&.find_node_by_name('node1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'prefix' => [
        { '_diff_state_' => @default_diff_state, 'prefix' => '192.168.0.0/24', 'metric' => 1, 'flag' => 'test'},
        { '_diff_state_' => @default_diff_state, 'prefix' => '192.168.1.0/24', 'metric' => 10, 'flag' => %w[foo bar]}
      ],
      'router-id' => ['192.168.0.1'],
      'flag' => %w[layer3 node],
      'name' => 'node1'
    }
    expect(attr&.to_data).to eq expected_attr
  end

  # TODO: L2 network attribute, it changed RFC8944
end
