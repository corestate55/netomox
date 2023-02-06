# frozen_string_literal: true

RSpec.describe 'link diff with L2 attribute', :attr, :diff, :l2attr, :link do
  before do
    link_attr = { name: 'linkX', flags: [], rate: 1000, delay: 10, srlg: '' }
    link_attr_changed = { name: 'linkX', flags: [], rate: 1000, delay: 20, srlg: '' }

    parent = lambda do |name|
      nws = Netomox::DSL::Networks.new
      Netomox::DSL::Network.new(nws, name) do
        type Netomox::NWTYPE_L2
      end
    end
    link_spec = %w[link1 tp1 link2 tp2]
    link_l2attr0_def = Netomox::DSL::Link.new(parent.call('nw0'), *link_spec)
    link_l2attr_def = Netomox::DSL::Link.new(parent.call('nw1'), *link_spec) do
      attribute(link_attr)
    end
    link_l2attr_changed_def = Netomox::DSL::Link.new(parent.call('nw2'), *link_spec) do
      attribute(link_attr_changed)
    end

    @link_l2attr0 = Netomox::Topology::Link.new(link_l2attr0_def.topo_data, '')
    @link_l2attr = Netomox::Topology::Link.new(link_l2attr_def.topo_data, '')
    @link_l2attr_changed = Netomox::Topology::Link.new(link_l2attr_changed_def.topo_data, '')
  end

  it 'kept link L2 attributes' do
    d_link = @link_l2attr.diff(@link_l2attr.dup)
    expect(d_link.diff_state.detect).to eq :kept
    expect(d_link.attribute.diff_state.detect).to eq :kept
  end

  context 'diff with no-attribute link' do
    it 'added whole L2 attribute' do
      d_link = @link_l2attr0.diff(@link_l2attr)
      expect(d_link.diff_state.detect).to eq :changed
      expect(d_link.attribute.diff_state.detect).to eq :added
    end

    it 'deleted whole L2 attribute' do
      d_link = @link_l2attr.diff(@link_l2attr0)
      expect(d_link.diff_state.detect).to eq :changed
      expect(d_link.attribute.diff_state.detect).to eq :deleted
    end
  end

  it 'changed link L2 attributes' do
    d_link = @link_l2attr.diff(@link_l2attr_changed)
    expect(d_link.diff_state.detect).to eq :changed
    expect(d_link.attribute.diff_state.detect).to eq :changed
  end
end
