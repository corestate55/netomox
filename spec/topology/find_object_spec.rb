# frozen_string_literal: true

RSpec.describe 'check network search functions' do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'layer1' do
        type Netomox::NWTYPE_MDDO_L1
        node 'l1node1' do
          term_point 'l1eth1'
        end
        node 'l1node2' do
          term_point 'l1eth2'
        end
        bdlink %w[l1node1 l1eth1 l1node2 l1eth2]
      end

      network 'layer2' do
        type Netomox::NWTYPE_MDDO_L2
        support 'layer1'
        node 'l2node1' do
          support %w[layer1 l1node1]
          term_point 'l2eth1' do
            support %w[layer1 l1node1 l1eth1]
          end
        end
      end

      network 'dummy-layer2' do
        type Netomox::NWTYPE_MDDO_L2
      end
    end
    topo_data = nws.topo_data
    @nws = Netomox::Topology::Networks.new(topo_data)
  end

  it 'find networks by type' do
    found_nws = @nws.find_all_networks_by_type(Netomox::NWTYPE_MDDO_L2)

    expect(found_nws.map(&:name)).to eq %w[layer2 dummy-layer2]
  end

  it 'find support network by support-network' do
    support_nw = @nws.find_network('layer2')&.supports&.[](0)
    found_nw = @nws.find_object_by_support(support_nw)

    expect(found_nw&.name).to eq 'layer1'
  end

  it 'find support node by support-node' do
    support_node = @nws.find_node('layer2', 'l2node1')&.supports&.[](0)
    found_node = @nws.find_object_by_support(support_node)

    expect(found_node&.name).to eq 'l1node1'
  end

  it 'find support tp by support-tp' do
    support_tp = @nws.find_tp('layer2', 'l2node1', 'l2eth1')&.supports&.[](0)
    found_tp = @nws.find_object_by_support(support_tp)

    expect(found_tp&.name).to eq 'l1eth1'
  end

  it 'find tp by link-edge' do
    l1_nw = @nws.find_network('layer1')
    link = l1_nw&.find_link_by_source('l1node1', 'l1eth1')
    dst_node, dst_tp = l1_nw&.find_node_tp_by_edge(link.destination)

    expect("#{dst_node.name}[#{dst_tp.name}]").to eq 'l1node2[l1eth2]'
  end
end
