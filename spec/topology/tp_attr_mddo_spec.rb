# frozen_string_literal: true

RSpec.describe 'check term-point attribute with RFC' do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'nw1' do
        type Netomox::NWTYPE_MDDO_L1
        node('node1') do
          term_point('eth1') do
            attribute(
              description: "descr of layer1 node1 eth1",
              flags: %w[layer1 term-point]
            )
          end
        end
      end
      network 'nw2' do
        type Netomox::NWTYPE_MDDO_L2
        node('node1') do
          term_point('eth1') do
            attribute(
              description: "descr of layer2 node1 eth1",
              encapsulation: 'dot1q',
              switchport_mode: 'trunk',
              flags: %w[layer2 term-point]
            )
          end
        end
      end
      network 'nw3' do
        type Netomox::NWTYPE_MDDO_L3
        node('node1') do
          term_point('eth1') do
            attribute(
              description: "descr of layer3 node1 eth1",
              ip_addrs: %w[192.168.0.1/24 169.254.0.1],
              flags: %w[layer3 term-point]
            )
          end
        end
      end
    end
    topo_data = nws.topo_data
    @nws = Netomox::Topology::Networks.new(topo_data)
    @default_diff_state = { :backward=>nil, :forward=>:kept, :pair=>"" }
  end

  it 'has MDDO layer1 term-point attribute' do
    attr = @nws.find_network('nw1')&.find_node_by_name('node1')&.find_tp_by_name('eth1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'description' => "descr of layer1 node1 eth1",
      'flag' => %w[layer1 term-point]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO layer2 term-point attribute' do
    attr = @nws.find_network('nw2')&.find_node_by_name('node1')&.find_tp_by_name('eth1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'description' => "descr of layer2 node1 eth1",
      'encapsulation' => 'dot1q',
      'switchport-mode' => 'trunk',
      'flag' => %w[layer2 term-point]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO layer3 term-point attribute' do
    attr = @nws.find_network('nw3')&.find_node_by_name('node1')&.find_tp_by_name('eth1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'description' => "descr of layer3 node1 eth1",
      'ip-address' => %w[192.168.0.1/24 169.254.0.1],
      'flag' => %w[layer3 term-point]
    }
    expect(attr&.to_data).to eq expected_attr
  end
end
