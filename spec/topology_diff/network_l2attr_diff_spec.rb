# frozen_string_literal: true

RSpec.describe 'network diff with L2 attribute', :diff, :network, :attr, :l2attr do
  before do
    parent = -> { Netomox::DSL::Networks.new }
    nw_l2attr0_def = Netomox::DSL::Network.new(parent.call, 'nwX') do
      type Netomox::NWTYPE_L2
    end
    nw_l2attr_def = Netomox::DSL::Network.new(parent.call, 'nwX') do
      type Netomox::NWTYPE_L2
      attribute(name: 'nwX', flags: %w[foo bar baz])
    end
    nw_l2attr_changed_def = Netomox::DSL::Network.new(parent.call, 'nwX') do
      type Netomox::NWTYPE_L2
      attribute(name: 'nwX', flags: %w[foo bar hoge])
    end

    @nw_l2attr0 = Netomox::Topology::Network.new(nw_l2attr0_def.topo_data)
    @nw_l2attr = Netomox::Topology::Network.new(nw_l2attr_def.topo_data)
    @nw_l2attr_changed = Netomox::Topology::Network.new(nw_l2attr_changed_def.topo_data)
  end

  it 'kept nw L2 attributes' do
    d_nw = @nw_l2attr.diff(@nw_l2attr.dup)
    expect(d_nw.diff_state.detect).to eq :kept
    expect(d_nw.attribute.diff_state.detect).to eq :kept
  end

  context 'diff with no-attribute nw' do
    it 'added whole L2 attribute' do
      d_nw = @nw_l2attr0.diff(@nw_l2attr)
      expect(d_nw.diff_state.detect).to eq :changed
      expect(d_nw.attribute.diff_state.detect).to eq :added
    end

    it 'deleted whole L2 attribute' do
      d_nw = @nw_l2attr.diff(@nw_l2attr0)
      expect(d_nw.diff_state.detect).to eq :changed
      expect(d_nw.attribute.diff_state.detect).to eq :deleted
    end
  end

  it 'changed nw L2 attributes' do
    d_nw = @nw_l2attr.diff(@nw_l2attr_changed)
    expect(d_nw.diff_state.detect).to eq :changed
    expect(d_nw.attribute.diff_state.detect).to eq :changed
  end
end
