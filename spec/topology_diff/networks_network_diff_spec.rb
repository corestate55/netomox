# frozen_string_literal: true

RSpec.describe 'networks diff (network list)', :diff, :network, :networks do
  context 'when network literal attribute changed' do
    before do
      nws_nw0_def = Netomox::DSL::Networks.new
      nws_nw1_def = Netomox::DSL::Networks.new do
        network 'nwX'
      end
      nws_nw2_def = Netomox::DSL::Networks.new do
        network 'nwX'
        network 'nwY'
      end
      nws_nw2_changed_def = Netomox::DSL::Networks.new do
        network 'nwX'
        network 'nwYaa'
      end
      @nws_nw0 = Netomox::Topology::Networks.new(nws_nw0_def.topo_data)
      @nws_nw1 = Netomox::Topology::Networks.new(nws_nw1_def.topo_data)
      @nws_nw2 = Netomox::Topology::Networks.new(nws_nw2_def.topo_data)
      @nws_nw2_changed = Netomox::Topology::Networks.new(nws_nw2_changed_def.topo_data)
    end

    context '0 to N, N to 0' do
      it 'added nws nw (0 -> 1)' do
        d_nws = @nws_nw0.diff(@nws_nw1)
        expect(d_nws.diff_state.detect).to eq :changed
        list = d_nws.networks.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[added]
      end

      it 'deleted nws nw (1 -> 0)' do
        d_nws = @nws_nw1.diff(@nws_nw0)
        expect(d_nws.diff_state.detect).to eq :changed
        list = d_nws.networks.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[deleted]
      end
    end

    context 'N to M, M to N' do
      it 'added nws nw (1 -> 2)' do
        d_nws = @nws_nw1.diff(@nws_nw2)
        expect(d_nws.diff_state.detect).to eq :changed
        list = d_nws.networks.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[added kept]
      end

      it 'added nws nw (1 -> 2)' do
        d_nws = @nws_nw2.diff(@nws_nw1)
        expect(d_nws.diff_state.detect).to eq :changed
        list = d_nws.networks.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[deleted kept]
      end
    end

    it 'changed nws nw' do
      d_nws = @nws_nw2.diff(@nws_nw2_changed)
      expect(d_nws.diff_state.detect).to eq :changed
      list = d_nws.networks.map { |t| t.diff_state.detect }
      expect(list.sort).to eq %i[added deleted kept]
    end
  end
end
