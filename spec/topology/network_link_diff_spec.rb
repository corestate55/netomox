RSpec.describe 'network diff (nw list)', :diff, :network, :nw do
  context 'when nw list changed' do
    before do
      nw_link0_def = Netomox::DSL::Network.new('nwX')
      nw_link1_def = Netomox::DSL::Network.new('nwX') do
        bdlink %w[node1 tp1 node2 tp2]
      end
      nw_link2_def = Netomox::DSL::Network.new('nwX') do
        bdlink %w[node1 tp1 node2 tp2]
        bdlink %w[node3 tp1 node4 tp2]
      end
      nw_link2_changed_def = Netomox::DSL::Network.new('nwX') do
        bdlink %w[node1 tp1 node2 tp2]
        bdlink %w[node3xx tp1 node2 tp2]
      end
      @nw_link0 = Netomox::Topology::Network.new(nw_link0_def.topo_data)
      @nw_link1 = Netomox::Topology::Network.new(nw_link1_def.topo_data)
      @nw_link2 = Netomox::Topology::Network.new(nw_link2_def.topo_data)
      @nw_link2_changed = Netomox::Topology::Network.new(nw_link2_changed_def.topo_data)
    end

    context '0 to N, N to 0' do
      it 'added nw link (0 -> 1)' do
        d_nw = @nw_link0.diff(@nw_link1)
        expect(d_nw.diff_state.detect).to eq :changed
        list = d_nw.links.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[added added]
      end

      it 'deleted nw link (1 -> 0)' do
        d_nw = @nw_link1.diff(@nw_link0)
        expect(d_nw.diff_state.detect).to eq :changed
        list = d_nw.links.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[deleted deleted]
      end
    end

    context 'N to M, M to N' do
      it 'added nw link (1 -> 2)' do
        d_nw = @nw_link1.diff(@nw_link2)
        expect(d_nw.diff_state.detect).to eq :changed
        list = d_nw.links.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[added added kept kept]
      end

      it 'added nw link (1 -> 2)' do
        d_nw = @nw_link2.diff(@nw_link1)
        expect(d_nw.diff_state.detect).to eq :changed
        list = d_nw.links.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[deleted deleted kept kept]
      end
    end

    it 'changed nw link' do
      d_nw = @nw_link2.diff(@nw_link2_changed)
      expect(d_nw.diff_state.detect).to eq :changed
      list = d_nw.links.map { |t| t.diff_state.detect }
      expect(list.sort).to eq %i[added added deleted deleted kept kept]
    end
  end
end
