# frozen_string_literal: true

RSpec.describe 'termination point diff with L3 attribute', :diff, :tp, :attr, :l3attr do
  before do
    tp_attr = { ip_addrs: %w[192.168.0.1 192.168.1.1] }
    tp_attr_added = { ip_addrs: %w[192.168.0.1 192.168.1.1 192.168.2.1] }
    tp_attr_deleted = { ip_addrs: %w[192.168.0.1] }
    tp_attr_changed = { ip_addrs: %w[192.168.0.1 192.168.1.2] }

    parent = lambda do |name|
      nws = Netomox::DSL::Networks.new do
        network 'nwX' do
          type Netomox::NWTYPE_L3
          node name
        end
      end
      nws.network('nwX').node(name)
    end
    tp_l3attr0_def = Netomox::DSL::TermPoint.new(parent.call('nd0'), 'tpX')
    tp_l3attr_def = Netomox::DSL::TermPoint.new(parent.call('nd1'), 'tpX') do
      attribute(tp_attr)
    end
    tp_l3attr_added_def = Netomox::DSL::TermPoint.new(parent.call('nd2'), 'tpX') do
      attribute(tp_attr_added)
    end
    tp_l3attr_deleted_def = Netomox::DSL::TermPoint.new(parent.call('nd3'), 'tpX') do
      attribute(tp_attr_deleted)
    end
    tp_l3attr_changed_def = Netomox::DSL::TermPoint.new(parent.call('nd4'), 'tpX') do
      attribute(tp_attr_changed)
    end

    @tp_l3attr0 = Netomox::Topology::TermPoint.new(tp_l3attr0_def.topo_data, '')
    @tp_l3attr = Netomox::Topology::TermPoint.new(tp_l3attr_def.topo_data, '')
    @tp_l3attr_added = Netomox::Topology::TermPoint.new(tp_l3attr_added_def.topo_data, '')
    @tp_l3attr_deleted = Netomox::Topology::TermPoint.new(tp_l3attr_deleted_def.topo_data, '')
    @tp_l3attr_changed = Netomox::Topology::TermPoint.new(tp_l3attr_changed_def.topo_data, '')
  end

  it 'kept tp L3 attribute' do
    d_tp = @tp_l3attr.diff(@tp_l3attr.dup)
    expect(d_tp.diff_state.detect).to eq :kept
    expect(d_tp.attribute.diff_state.detect).to eq :kept
  end

  context 'diff with no-attribute tp' do
    it 'added whole L3 attribute' do
      d_tp = @tp_l3attr0.diff(@tp_l3attr)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :added
    end

    it 'deleted whole L3 attribute' do
      d_tp = @tp_l3attr.diff(@tp_l3attr0)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :deleted
    end
  end

  it 'added tp L3 attribute' do
    d_tp = @tp_l3attr.diff(@tp_l3attr_added)
    expect(d_tp.diff_state.detect).to eq :changed
    expect(d_tp.attribute.diff_state.detect).to eq :changed
  end

  it 'deleted tp L3 attribute' do
    d_tp = @tp_l3attr.diff(@tp_l3attr_deleted)
    expect(d_tp.diff_state.detect).to eq :changed
    expect(d_tp.attribute.diff_state.detect).to eq :changed
  end

  it 'changed tp L3 attribute' do
    d_tp = @tp_l3attr.diff(@tp_l3attr_changed)
    expect(d_tp.diff_state.detect).to eq :changed
    expect(d_tp.attribute.diff_state.detect).to eq :changed
  end
end
