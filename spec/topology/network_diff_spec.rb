RSpec.describe 'network diff (supporting-node list)', :diff, :network do
  context 'when network literal attribute changed' do
    before do
      l2nw_def = Netomox::DSL::Network.new('nwX') do
        type Netomox::DSL::NWTYPE_L2
      end
      l3nw_def = Netomox::DSL::Network.new('nwX') do
        type Netomox::DSL::NWTYPE_L3
      end
      @l2nw = Netomox::Topology::Network.new(l2nw_def.topo_data)
      @l3nw = Netomox::Topology::Network.new(l3nw_def.topo_data)
    end

    it 'kept kept network info' do
      d_nw = @l2nw.diff(@l2nw.dup)
      expect(d_nw.diff_state.detect).to eq :kept
    end

    it 'changed by network type' do
      d_nw = @l2nw.diff(@l3nw)
      expect(d_nw.diff_state.detect).to eq :changed
    end
  end

  context 'when support network list changed', :support do
    before do
      nw_sup0_def = Netomox::DSL::Network.new('nwX')
      nw_sup1_def = Netomox::DSL::Network.new('nwX') do
        support 'nw1'
      end
      nw_sup2_def = Netomox::DSL::Network.new('nwX') do
        support 'nw1'
        support 'nw2'
      end
      nw_sup2_changed_def = Netomox::DSL::Network.new('nwX') do
        support 'nw1'
        support 'nw2aa'
      end

      @nw_sup0 = Netomox::Topology::Network.new(nw_sup0_def.topo_data)
      @nw_sup1 = Netomox::Topology::Network.new(nw_sup1_def.topo_data)
      @nw_sup2 = Netomox::Topology::Network.new(nw_sup2_def.topo_data)
      @nw_sup2_changed = Netomox::Topology::Network.new(nw_sup2_changed_def.topo_data)
    end

    it 'kept nw supports' do
      d_nw = @nw_sup1.diff(@nw_sup1.dup)
      expect(d_nw.diff_state.detect).to eq :kept
      list = d_nw.supports.map { |s| s.diff_state.detect }
      expect(list.sort).to eq %i[kept]
    end

    context '0 to N, N to 0' do
      it 'added tp support (0 -> 1)' do
        d_nw = @nw_sup0.diff(@nw_sup1)
        expect(d_nw.diff_state.detect).to eq :changed
        list = d_nw.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[added]
      end

      it 'added tp support (1 -> 0)' do
        d_nw = @nw_sup1.diff(@nw_sup0)
        expect(d_nw.diff_state.detect).to eq :changed
        list = d_nw.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[deleted]
      end
    end

    context 'N to M, M to N' do
      it 'added tp support (1 -> 2)' do
        d_nw = @nw_sup1.diff(@nw_sup2)
        expect(d_nw.diff_state.detect).to eq :changed
        list = d_nw.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[added kept]
      end

      it 'added tp support (2 -> 1)' do
        d_nw = @nw_sup2.diff(@nw_sup1)
        expect(d_nw.diff_state.detect).to eq :changed
        list = d_nw.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[deleted kept]
      end
    end

    it 'changed support nw' do
      d_nw = @nw_sup2.diff(@nw_sup2_changed)
      expect(d_nw.diff_state.detect).to eq :changed
      list = d_nw.supports.map { |s| s.diff_state.detect }
      expect(list.sort).to eq %i[added deleted kept]
    end
  end
end
