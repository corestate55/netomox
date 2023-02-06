# frozen_string_literal: true

RSpec.describe 'network diff with ospf-area attribute', :attr, :diff, :network, :ospf_attr do
  before do
    parent = -> { Netomox::DSL::Networks.new }
    nw_ospf_attr_empty_def = Netomox::DSL::Network.new(parent.call, 'ospf') do
      type Netomox::NWTYPE_MDDO_OSPF_AREA
    end
    nw_ospf_attr_a0_def = Netomox::DSL::Network.new(parent.call, 'ospf') do
      type Netomox::NWTYPE_MDDO_OSPF_AREA
      attribute(identifier: '0.0.0.0')
    end
    nw_ospf_attr_a1_def = Netomox::DSL::Network.new(parent.call, 'ospf') do
      type Netomox::NWTYPE_MDDO_OSPF_AREA
      attribute(identifier: '0.0.0.1')
    end

    @nw_attr_empty = Netomox::Topology::Network.new(nw_ospf_attr_empty_def.topo_data)
    @nw_attr_a0 = Netomox::Topology::Network.new(nw_ospf_attr_a0_def.topo_data)
    @nw_attr_a1 = Netomox::Topology::Network.new(nw_ospf_attr_a1_def.topo_data)
  end

  it 'kept nw ospf attributes' do
    d_nw = @nw_attr_a0.diff(@nw_attr_a0.dup)
    expect(d_nw.diff_state.detect).to eq :kept
    expect(d_nw.attribute.diff_state.detect).to eq :kept
  end

  context 'diff with no-attribute nw' do
    it 'added whole ospf attribute' do
      d_nw = @nw_attr_empty.diff(@nw_attr_a0)
      expect(d_nw.diff_state.detect).to eq :changed
      expect(d_nw.attribute.diff_state.detect).to eq :added
    end

    it 'deleted whole ospf attribute' do
      d_nw = @nw_attr_a0.diff(@nw_attr_empty)
      expect(d_nw.diff_state.detect).to eq :changed
      expect(d_nw.attribute.diff_state.detect).to eq :deleted
    end

    it 'changed ospf attributes' do
      d_nw = @nw_attr_a0.diff(@nw_attr_a1)
      expect(d_nw.diff_state.detect).to eq :changed
      expect(d_nw.attribute.diff_state.detect).to eq :changed
    end
  end
end
