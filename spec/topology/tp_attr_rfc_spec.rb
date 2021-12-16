# frozen_string_literal: true

RSpec.describe 'check term-point attribute with RFC' do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'nw1' do
        type Netomox::NWTYPE_L3
        node('node1') do
          term_point('eth1') do
            attribute(
              ip_addrs: %w[192.168.0.1/24 169.254.0.1]
            )
          end
        end
      end
    end
    topo_data = nws.topo_data
    @nws = Netomox::Topology::Networks.new(topo_data)
    @default_diff_state = { backward: nil, forward: :kept, pair: '' }
  end

  it 'has rfc8345-based node attribute' do
    attr = @nws.find_network('nw1')&.find_node_by_name('node1')&.find_tp_by_name('eth1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'ip-address' => %w[192.168.0.1/24 169.254.0.1]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  # TODO: L2 network attribute, it changed RFC8944
end
