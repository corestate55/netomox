# frozen_string_literal: true

RSpec.describe 'node diff with ospf-area attribute', :diff, :node, :attr, :ospf_attr do
  before do
    parent = lambda do |name|
      nws = Netomox::DSL::Networks.new
      Netomox::DSL::Network.new(nws, name) do
        type Netomox::NWTYPE_MDDO_OSPF_AREA
      end
    end

    attr1 = {
      node_type: 'ospf_proc',
      router_id: '192.168.0.1',
      redistribute: [
        { protocol: 'static', metric_type: 2 }
      ]
    }
    attr2 = {
      node_type: 'ospf_proc',
      router_id: '192.168.0.2', # change
      redistribute: [
        { protocol: 'static', metric_type: 2 }
      ]
    }
    attr3 = {
      node_type: 'ospf_proc',
      router_id: '192.168.0.1',
      redistribute: [
        { protocol: 'static', metric_type: 1 } # change internal
      ]
    }
    attr4 = {
      node_type: 'ospf_proc',
      router_id: '192.168.0.2', # change
      redistribute: [
        { protocol: 'static', metric_type: 2 },
        { protocol: 'connected', metric_type: 2 } # added internal
      ]
    }

    node_ospf_attr_empty = Netomox::DSL::Node.new(parent.call('ospf'), 'nodeX')
    node_ospf_attr1 = Netomox::DSL::Node.new(parent.call('ospf'), 'nodeX') do
      attribute(attr1)
    end
    node_ospf_attr2 = Netomox::DSL::Node.new(parent.call('ospf'), 'nodeX') do
      attribute(attr2)
    end
    node_ospf_attr3 = Netomox::DSL::Node.new(parent.call('ospf'), 'nodeX') do
      attribute(attr3)
    end
    node_ospf_attr4 = Netomox::DSL::Node.new(parent.call('ospf'), 'nodeX') do
      attribute(attr4)
    end

    @node_ospf_attr_empty = Netomox::Topology::Node.new(node_ospf_attr_empty.topo_data, '')
    @node_ospf_attr1 = Netomox::Topology::Node.new(node_ospf_attr1.topo_data, '')
    @node_ospf_attr2 = Netomox::Topology::Node.new(node_ospf_attr2.topo_data, '')
    @node_ospf_attr3 = Netomox::Topology::Node.new(node_ospf_attr3.topo_data, '')
    @node_ospf_attr4 = Netomox::Topology::Node.new(node_ospf_attr4.topo_data, '')
  end

  it 'kept ospf attribute' do
    d_node = @node_ospf_attr1.diff(@node_ospf_attr1.dup)
    expect(d_node.diff_state.detect).to eq :kept
    expect(d_node.attribute.diff_state.detect).to eq :kept
    list = d_node.attribute.redistribute_list.map { |d| d.diff_state.detect }
    expect(list).to eq %i[kept]
  end

  context 'diff with no-attribute node' do
    it 'added whole ospf attribute' do
      d_node = @node_ospf_attr_empty.diff(@node_ospf_attr1)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :added
      list = d_node.attribute.redistribute_list.map { |d| d.diff_state.detect }
      expect(list).to eq %i[added]
    end

    it 'deleted whole ospf attribute' do
      d_node = @node_ospf_attr1.diff(@node_ospf_attr_empty)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :deleted
      list = d_node.attribute.redistribute_list.map { |d| d.diff_state.detect }
      expect(list).to eq %i[deleted]
    end
  end

  context 'diff with sub-attribute of node attribute' do
    it 'changed a literal attribute' do
      d_node = @node_ospf_attr1.diff(@node_ospf_attr2)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      list = d_node.attribute.redistribute_list.map { |d| d.diff_state.detect }
      expect(list).to eq %i[kept]
    end

    it 'changed a sub-attribute' do
      d_node = @node_ospf_attr1.diff(@node_ospf_attr3)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      list = d_node.attribute.redistribute_list.map { |d| d.diff_state.detect }
      # NOTICE:
      # redistribute attribute { protocol: static, metric_type:2 } != { protocol: static, metric_type: 1}
      # so, it will be `added` and `deleted`, not `kept`
      expect(list).to eq %i[deleted added]
    end

    it 'added a sub-attribute' do
      d_node = @node_ospf_attr1.diff(@node_ospf_attr4)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      list = d_node.attribute.redistribute_list.map { |d| d.diff_state.detect }
      expect(list).to eq %i[kept added]
    end

    it 'deleted a sub-attribute' do
      d_node = @node_ospf_attr4.diff(@node_ospf_attr1)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      list = d_node.attribute.redistribute_list.map { |d| d.diff_state.detect }
      expect(list).to eq %i[kept deleted]
    end
  end
end
