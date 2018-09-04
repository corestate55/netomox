require_relative '../spec_helper'

describe 'node diff with L2 attribute', :diff, :node, :attr, :l2attr do
  before do
    l3nw_type = { NWTopoDSL::NWTYPE_L2 => {} }
    addrs = %w[192.168.0.1 192.168.1.1]
    addrs_added = %w[192.168.0.1 192.168.1.1 192.168.2.1]
    addrs_deleted = %w[192.168.0.1]

    node_attr = { name: 'tpX', mgmt_vid: 10, mgmt_addrs: addrs }
    node_attr_added = { name: 'tpX', mgmt_vid: 10, mgmt_addrs: addrs_added }
    node_attr_deleted = { name: 'tpX', mgmt_vid: 10, mgmt_addrs: addrs_deleted }
    node_attr_changed = { name: 'tpX', mgmt_vid: 11, mgmt_addrs: addrs }

    node_l3attr0_def = NWTopoDSL::Node.new('nodeX', l3nw_type)
    node_l3attr_def = NWTopoDSL::Node.new('nodeX', l3nw_type) do
      attribute(node_attr)
    end
    node_l3attr_added_def = NWTopoDSL::Node.new('nodeX', l3nw_type) do
      attribute(node_attr_added)
    end
    node_l3attr_deleted_def = NWTopoDSL::Node.new('nodeX', l3nw_type) do
      attribute(node_attr_deleted)
    end
    node_l3attr_changed_def = NWTopoDSL::Node.new('nodeX', l3nw_type) do
      attribute(node_attr_changed)
    end

    @node_l3attr0 = TopoChecker::Node.new(node_l3attr0_def.topo_data, '')
    @node_l3attr = TopoChecker::Node.new(node_l3attr_def.topo_data, '')
    @node_l3attr_added = TopoChecker::Node.new(node_l3attr_added_def.topo_data, '')
    @node_l3attr_deleted = TopoChecker::Node.new(node_l3attr_deleted_def.topo_data, '')
    @node_l3attr_changed = TopoChecker::Node.new(node_l3attr_changed_def.topo_data, '')
  end

  it 'kept tp L3 attribute' do
    d_node = @node_l3attr.diff(@node_l3attr.dup)
    expect(d_node.diff_state.detect).to eq :kept
    expect(d_node.attribute.diff_state.detect).to eq :kept
  end

  context 'diff with no-attribute node' do
    it 'added whole L3 attribute' do
      d_node = @node_l3attr0.diff(@node_l3attr)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :added
    end

    it 'added whole L3 attribute' do
      d_node = @node_l3attr.diff(@node_l3attr0)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :deleted
    end
  end

  it 'added node L3 attribute' do
    d_node = @node_l3attr.diff(@node_l3attr_added)
    expect(d_node.diff_state.detect).to eq :changed
    expect(d_node.attribute.diff_state.detect).to eq :changed
  end

  it 'deleted node L3 attribute' do
    d_node = @node_l3attr.diff(@node_l3attr_deleted)
    expect(d_node.diff_state.detect).to eq :changed
    expect(d_node.attribute.diff_state.detect).to eq :changed
  end

  it 'changed node L3 attribute' do
    d_node = @node_l3attr.diff(@node_l3attr_changed)
    expect(d_node.diff_state.detect).to eq :changed
    expect(d_node.attribute.diff_state.detect).to eq :changed
  end
end
