RSpec.describe 'node diff with L3 attribute', :diff, :node, :attr, :l3attr do
  before do
    seg_a_prefix = { prefix: '192.168,10.0/24', metric: 100 }
    seg_a2_prefix = { prefix: '192.168,10.0/24', metric: 50 }
    seg_b_prefix = { prefix: '192.168.20.0/24', metric: 100 }
    seg_c_prefix = { prefix: '192.168.30.0/24', metric: 100 }

    pref = { prefixes: [seg_a_prefix, seg_b_prefix] }
    pref_added = { prefixes: [seg_a_prefix, seg_b_prefix, seg_c_prefix] }
    pref_deleted = { prefixes: [seg_b_prefix] }
    pref_changed = { prefixes: [seg_a2_prefix, seg_b_prefix] }

    parent = lambda do |name|
      nws = Netomox::DSL::Networks.new
      Netomox::DSL::Network.new(nws, name) do
        type Netomox::NWTYPE_L3
      end
    end
    node_l3attr0_def = Netomox::DSL::Node.new(parent.call('nw0'), 'nodeX')
    node_l3attr_def = Netomox::DSL::Node.new(parent.call('nw1'), 'nodeX') do
      attribute(pref)
    end
    node_l3attr_added_def = Netomox::DSL::Node.new(parent.call('nw2'), 'nodeX') do
      attribute(pref_added)
    end
    node_l3attr_deleted_def = Netomox::DSL::Node.new(parent.call('nw3'), 'nodeX') do
      attribute(pref_deleted)
    end
    node_l3attr_changed_def = Netomox::DSL::Node.new(parent.call('nw4'), 'nodeX') do
      attribute(pref_changed)
    end

    @node_l3attr0 = Netomox::Topology::Node.new(node_l3attr0_def.topo_data, '')
    @node_l3attr = Netomox::Topology::Node.new(node_l3attr_def.topo_data, '')
    @node_l3attr_added = Netomox::Topology::Node.new(node_l3attr_added_def.topo_data, '')
    @node_l3attr_deleted = Netomox::Topology::Node.new(node_l3attr_deleted_def.topo_data, '')
    @node_l3attr_changed = Netomox::Topology::Node.new(node_l3attr_changed_def.topo_data, '')
  end

  it 'kept L3 attribute' do
    d_node = @node_l3attr.diff(@node_l3attr.dup)
    expect(d_node.diff_state.detect).to eq :kept
    expect(d_node.attribute.diff_state.detect).to eq :kept
    list = d_node.attribute.prefixes.map { |d| d.diff_state.detect }
    expect(list.sort).to eq %i[kept kept]
  end

  context 'diff with no-attribute node' do
    it 'added whole L3 attribute' do
      d_node = @node_l3attr0.diff(@node_l3attr)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :added
      list = d_node.attribute.prefixes.map { |d| d.diff_state.detect }
      expect(list.sort).to eq %i[added added]
    end

    it 'deleted whole L3 attribute' do
      d_node = @node_l3attr.diff(@node_l3attr0)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :deleted
      list = d_node.attribute.prefixes.map { |d| d.diff_state.detect }
      expect(list.sort).to eq %i[deleted deleted]
    end
  end

  context 'diff with sub-attribute of node attribute' do
    it 'added prefixes' do
      d_node = @node_l3attr.diff(@node_l3attr_added)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      list = d_node.attribute.prefixes.map { |d| d.diff_state.detect }
      expect(list.sort).to eq %i[added kept kept]
    end

    it 'deleted prefixes' do
      d_node = @node_l3attr.diff(@node_l3attr_deleted)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      list = d_node.attribute.prefixes.map { |d| d.diff_state.detect }
      expect(list.sort).to eq %i[deleted kept]
    end

    it 'changed prefixes' do
      d_node = @node_l3attr.diff(@node_l3attr_changed)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      list = d_node.attribute.prefixes.map { |d| d.diff_state.detect }
      expect(list.sort).to eq %i[added deleted kept]
    end
  end
end
