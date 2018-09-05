RSpec.describe 'termination point diff with L2 attribute', :diff, :tp, :attr, :l2attr do
  before do
    l2nw_type = {Netomox::DSL::NWTYPE_L2 => {} }

    vlan_a = { id: 10, name: 'Seg.A' }
    vlan_b = { id: 20, name: 'Seg.B' }
    vlan_a_changed = { id: 11, name: 'Seg.A' }
    access_vlan_a = {
      port_vlan_id: 10,
      vlan_id_names: [vlan_a, vlan_b]
    }
    access_vlan_a_added = {
      port_vlan_id: 10,
      vlan_id_names: [vlan_a, vlan_a_changed, vlan_b]
    }
    access_vlan_a_deleted = {
      port_vlan_id: 10,
      vlan_id_names: [vlan_a]
    }
    access_vlan_a_changed = {
      port_vlan_id: 10,
      vlan_id_names: [vlan_a_changed, vlan_b]
    }

    tp_l2attr0_def = Netomox::DSL::TermPoint.new('tpX', l2nw_type)
    tp_l2attr_def = Netomox::DSL::TermPoint.new('tpX', l2nw_type) do
      attribute(access_vlan_a)
    end
    tp_l2attr_added_def = Netomox::DSL::TermPoint.new('tpX', l2nw_type) do
      attribute(access_vlan_a_added)
    end
    tp_l2attr_deleted_def = Netomox::DSL::TermPoint.new('tpX', l2nw_type) do
      attribute(access_vlan_a_deleted)
    end
    tp_l2attr_changed_def = Netomox::DSL::TermPoint.new('tpX', l2nw_type) do
      attribute(access_vlan_a_changed)
    end

    @tp_l2attr0 = Netomox::Topology::TermPoint.new(tp_l2attr0_def.topo_data, '')
    @tp_l2attr = Netomox::Topology::TermPoint.new(tp_l2attr_def.topo_data, '')
    @tp_l2attr_added = Netomox::Topology::TermPoint.new(tp_l2attr_added_def.topo_data, '')
    @tp_l2attr_deleted = Netomox::Topology::TermPoint.new(tp_l2attr_deleted_def.topo_data, '')
    @tp_l2attr_changed = Netomox::Topology::TermPoint.new(tp_l2attr_changed_def.topo_data, '')
  end

  it 'kept tp L2 attribute' do
    d_tp = @tp_l2attr.diff(@tp_l2attr.dup)
    expect(d_tp.diff_state.detect).to eq :kept
    expect(d_tp.attribute.diff_state.detect).to eq :kept
    list = d_tp.attribute.vlan_id_names.map { |d| d.diff_state.detect }
    expect(list.sort).to eq %i[kept kept]
  end

  context 'diff with no-attribute tp' do
    it 'added whole L2 attribute' do
      d_tp = @tp_l2attr0.diff(@tp_l2attr)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :added
      list = d_tp.attribute.vlan_id_names.map { |d| d.diff_state.detect }
      expect(list.sort).to eq %i[added added]
    end

    it 'deleted whole L2 attribute' do
      d_tp = @tp_l2attr.diff(@tp_l2attr0)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :deleted
      list = d_tp.attribute.vlan_id_names.map { |d| d.diff_state.detect }
      expect(list.sort).to eq %i[deleted deleted]
    end
  end

  context 'diff with sub-attribute of tp attribute' do
    it 'added vlan_id_names' do
      d_tp = @tp_l2attr.diff(@tp_l2attr_added)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      list = d_tp.attribute.vlan_id_names.map { |d| d.diff_state.detect }
      expect(list.sort).to eq %i[added kept kept]
    end

    it 'deleted vlan_id_names' do
      d_tp = @tp_l2attr.diff(@tp_l2attr_deleted)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      list = d_tp.attribute.vlan_id_names.map { |d| d.diff_state.detect }
      expect(list.sort).to eq %i[deleted kept]
    end

    it 'changed vlan_id_names' do
      d_tp = @tp_l2attr.diff(@tp_l2attr_changed)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      list = d_tp.attribute.vlan_id_names.map { |d| d.diff_state.detect }
      expect(list.sort).to eq %i[added deleted kept]
    end
  end
end
