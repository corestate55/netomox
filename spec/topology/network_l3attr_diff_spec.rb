RSpec.describe 'network diff with L3 attribute', :diff, :network, :attr, :l3attr do
  before do
    nw_l3attr0_def = Netomox::DSL::Network.new('nwX') do
      type Netomox::NWTYPE_L3
    end
    nw_l3attr_def = Netomox::DSL::Network.new('nwX') do
      type Netomox::NWTYPE_L3
      attribute(name: 'nwX', flags: %w[foo bar baz])
    end
    nw_l3attr_changed_def = Netomox::DSL::Network.new('nwX') do
      type Netomox::NWTYPE_L3
      attribute(name: 'nwX', flags: %w[foo bar hoge])
    end

    @nw_l3attr0 = Netomox::Topology::Network.new(nw_l3attr0_def.topo_data)
    @nw_l3attr = Netomox::Topology::Network.new(nw_l3attr_def.topo_data)
    @nw_l3attr_changed = Netomox::Topology::Network.new(nw_l3attr_changed_def.topo_data)
  end

  it 'kept nw L3 attributes' do
    d_nw = @nw_l3attr.diff(@nw_l3attr.dup)
    expect(d_nw.diff_state.detect).to eq :kept
    expect(d_nw.attribute.diff_state.detect).to eq :kept
  end

  context 'diff with no-attribute nw' do
    it 'added whole L3 attribute' do
      d_nw = @nw_l3attr0.diff(@nw_l3attr)
      expect(d_nw.diff_state.detect).to eq :changed
      expect(d_nw.attribute.diff_state.detect).to eq :added
    end

    it 'deleted whole L3 attribute' do
      d_nw = @nw_l3attr.diff(@nw_l3attr0)
      expect(d_nw.diff_state.detect).to eq :changed
      expect(d_nw.attribute.diff_state.detect).to eq :deleted
    end
  end

  it 'changed nw L3 attributes' do
    d_nw = @nw_l3attr.diff(@nw_l3attr_changed)
    expect(d_nw.diff_state.detect).to eq :changed
    expect(d_nw.attribute.diff_state.detect).to eq :changed
  end
end
