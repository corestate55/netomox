RSpec.describe 'node diff with L2 attribute', :diff, :node, :attr, :l2attr do
  before do
    l2nw_type = { Netomox::NWTYPE_L2 => {} }
    addrs = %w[192.168.0.1 192.168.1.1]
    addrs_added = %w[192.168.0.1 192.168.1.1 192.168.2.1]
    addrs_deleted = %w[192.168.0.1]

    node_attr = { name: 'nodeX', mgmt_vid: 10, mgmt_addrs: addrs }
    node_attr_added = { name: 'nodeX', mgmt_vid: 10, mgmt_addrs: addrs_added }
    node_attr_deleted = { name: 'nodeX', mgmt_vid: 10, mgmt_addrs: addrs_deleted }
    node_attr_changed = { name: 'nodeX', mgmt_vid: 11, mgmt_addrs: addrs }

    node_l2attr0_def = Netomox::DSL::Node.new('nodeX', l2nw_type)
    node_l2attr_def = Netomox::DSL::Node.new('nodeX', l2nw_type) do
      attribute(node_attr)
    end
    node_l2attr_added_def = Netomox::DSL::Node.new('nodeX', l2nw_type) do
      attribute(node_attr_added)
    end
    node_l2attr_deleted_def = Netomox::DSL::Node.new('nodeX', l2nw_type) do
      attribute(node_attr_deleted)
    end
    node_l2attr_changed_def = Netomox::DSL::Node.new('nodeX', l2nw_type) do
      attribute(node_attr_changed)
    end

    @node_l2attr0 = Netomox::Topology::Node.new(node_l2attr0_def.topo_data, '')
    @node_l2attr = Netomox::Topology::Node.new(node_l2attr_def.topo_data, '')
    @node_l2attr_added = Netomox::Topology::Node.new(node_l2attr_added_def.topo_data, '')
    @node_l2attr_deleted = Netomox::Topology::Node.new(node_l2attr_deleted_def.topo_data, '')
    @node_l2attr_changed = Netomox::Topology::Node.new(node_l2attr_changed_def.topo_data, '')
  end

  it 'kept tp L2 attribute' do
    d_node = @node_l2attr.diff(@node_l2attr.dup)
    expect(d_node.diff_state.detect).to eq :kept
    expect(d_node.attribute.diff_state.detect).to eq :kept
  end

  context 'diff with no-attribute node' do
    it 'added whole L3 attribute' do
      d_node = @node_l2attr0.diff(@node_l2attr)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :added
    end

    it 'added whole L2 attribute' do
      d_node = @node_l2attr.diff(@node_l2attr0)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :deleted
    end
  end

  it 'added node L2 attribute' do
    d_node = @node_l2attr.diff(@node_l2attr_added)
    expect(d_node.diff_state.detect).to eq :changed
    expect(d_node.attribute.diff_state.detect).to eq :changed
  end

  it 'deleted node L2 attribute' do
    d_node = @node_l2attr.diff(@node_l2attr_deleted)
    expect(d_node.diff_state.detect).to eq :changed
    expect(d_node.attribute.diff_state.detect).to eq :changed
  end

  it 'changed node L2 attribute' do
    d_node = @node_l2attr.diff(@node_l2attr_changed)
    expect(d_node.diff_state.detect).to eq :changed
    expect(d_node.attribute.diff_state.detect).to eq :changed
  end
end
