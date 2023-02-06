# frozen_string_literal: true

RSpec.describe 'termination point diff with L2 attribute', :attr, :diff, :l2attr, :tp do
  before do
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

    parent = lambda do |name|
      nws = Netomox::DSL::Networks.new do
        network 'nwX' do
          type Netomox::NWTYPE_L2
          node name
        end
      end
      nws.network('nwX').node(name)
    end
    tp_l2attr0_def = Netomox::DSL::TermPoint.new(parent.call('nd0'), 'tpX')
    tp_l2attr_def = Netomox::DSL::TermPoint.new(parent.call('nd1'), 'tpX') do
      attribute(access_vlan_a)
    end
    tp_l2attr_added_def = Netomox::DSL::TermPoint.new(parent.call('nd2'), 'tpX') do
      attribute(access_vlan_a_added)
    end
    tp_l2attr_deleted_def = Netomox::DSL::TermPoint.new(parent.call('nd3'), 'tpX') do
      attribute(access_vlan_a_deleted)
    end
    tp_l2attr_changed_def = Netomox::DSL::TermPoint.new(parent.call('nd4'), 'tpX') do
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
    dd_expected = []
    expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
  end

  context 'diff with no-attribute tp' do
    it 'added whole L2 attribute' do
      d_tp = @tp_l2attr0.diff(@tp_l2attr)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :added
      dd_expected = [
        ['+', '_diff_state_', { forward: :kept, backward: nil, pair: '' }],
        ['+', 'description', ''],
        ['+', 'eth-encapsulation', ''],
        ['+', 'mac-address', ''],
        ['+', 'maximum-frame-size', 1500],
        ['+', 'port-vlan-id', 10],
        ['+', 'tp-state', 'in-use'],
        ['+', 'vlan-id-name', [
          { 'vlan-id' => 10, 'vlan-name' => 'Seg.A' },
          { 'vlan-id' => 20, 'vlan-name' => 'Seg.B' }
        ]]
      ]
      expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted whole L2 attribute' do
      d_tp = @tp_l2attr.diff(@tp_l2attr0)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :deleted
      dd_expected = [
        ['-', '_diff_state_', { forward: :kept, backward: nil, pair: '' }],
        ['-', 'description', ''],
        ['-', 'eth-encapsulation', ''],
        ['-', 'mac-address', ''],
        ['-', 'maximum-frame-size', 1500],
        ['-', 'port-vlan-id', 10],
        ['-', 'tp-state', 'in-use'],
        ['-', 'vlan-id-name', [
          { 'vlan-id' => 10, 'vlan-name' => 'Seg.A' },
          { 'vlan-id' => 20, 'vlan-name' => 'Seg.B' }
        ]]
      ]
      expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
    end
  end

  context 'diff with sub-attribute of tp attribute' do
    it 'added vlan_id_names' do
      d_tp = @tp_l2attr.diff(@tp_l2attr_added)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      dd_expected = [['+', 'vlan-id-name[1]', { 'vlan-id' => 11, 'vlan-name' => 'Seg.A' }]]
      expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted vlan_id_names' do
      d_tp = @tp_l2attr.diff(@tp_l2attr_deleted)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      dd_expected = [['-', 'vlan-id-name[1]', { 'vlan-id' => 20, 'vlan-name' => 'Seg.B' }]]
      expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'changed vlan_id_names' do
      d_tp = @tp_l2attr.diff(@tp_l2attr_changed)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'vlan-id-name[0]', { 'vlan-id' => 10, 'vlan-name' => 'Seg.A' }],
        ['+', 'vlan-id-name[0]', { 'vlan-id' => 11, 'vlan-name' => 'Seg.A' }]
      ]
      expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
    end
  end
end
