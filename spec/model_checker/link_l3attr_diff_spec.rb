require_relative '../spec_helper'

describe 'link diff with L3 attribute', :diff, :link, :attr, :l3attr do
  before do
    l3nw_type = { NWTopoDSL::NWTYPE_L3 => {} }
    link_attr = { name: 'linkX', flags: [], metric1: 100, metric2: 100 }
    link_attr_changed = { name: 'linkX', flags: [], metric1: 200, metric2: 200 }

    link_spec = %w[link1 tp1 link2 tp2]
    link_l3attr0_def = NWTopoDSL::Link.new(*link_spec, l3nw_type)
    link_l3attr_def = NWTopoDSL::Link.new(*link_spec, l3nw_type) do
      attribute(link_attr)
    end
    link_l3attr_changed_def = NWTopoDSL::Link.new(*link_spec, l3nw_type) do
      attribute(link_attr_changed)
    end

    @link_l3attr0 = TopoChecker::Link.new(link_l3attr0_def.topo_data, '')
    @link_l3attr = TopoChecker::Link.new(link_l3attr_def.topo_data, '')
    @link_l3attr_changed = TopoChecker::Link.new(link_l3attr_changed_def.topo_data, '')
  end

  it 'kept link L3 attributes' do
    d_link = @link_l3attr.diff(@link_l3attr.dup)
    expect(d_link.diff_state.detect).to eq :kept
    expect(d_link.attribute.diff_state.detect).to eq :kept
  end

  context 'diff with no-attribute link' do
    it 'added whole L3 attribute' do
      d_link = @link_l3attr0.diff(@link_l3attr)
      expect(d_link.diff_state.detect).to eq :changed
      expect(d_link.attribute.diff_state.detect).to eq :added
    end

    it 'deleted whole L3 attribute' do
      d_link = @link_l3attr.diff(@link_l3attr0)
      expect(d_link.diff_state.detect).to eq :changed
      expect(d_link.attribute.diff_state.detect).to eq :deleted
    end
  end

  it 'changed link L3 attributes' do
    d_link = @link_l3attr.diff(@link_l3attr_changed)
    expect(d_link.diff_state.detect).to eq :changed
    expect(d_link.attribute.diff_state.detect).to eq :changed
  end
end
