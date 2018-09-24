RSpec.describe 'termination point diff (supporting-tp list)', :diff, :tp do
  context 'when tp literal attribute changed' do
    before do
      nws = Netomox::DSL::Networks.new do
        network 'nwX' do
          node 'nodeX'
        end
      end
      parent = nws.network('nwX').node('nodeX')
      tp_def = Netomox::DSL::TermPoint.new(parent, 'tpX')
      @tp = Netomox::Topology::TermPoint.new(tp_def.topo_data, 'nodeX')
      @tp_kept = Netomox::Topology::TermPoint.new(tp_def.topo_data, 'nodeX')
      @tp_changed = Netomox::Topology::TermPoint.new(tp_def.topo_data, 'nodeY')
    end

    it 'kept tp info' do
      expect(@tp.diff(@tp_kept).diff_state.detect).to eq :kept
    end

    it 'changed by parent path' do
      expect(@tp.diff(@tp_changed).diff_state.detect).to eq :changed
    end
  end

  context 'when support tp list changed', :support do
    before do
      parent = lambda do |name|
        nws = Netomox::DSL::Networks.new do
          network 'nwX' do
            node name
          end
        end
        nws.network('nwX').node(name)
      end
      tp_sup0_def = Netomox::DSL::TermPoint.new(parent.call('nd0'), 'tpX')
      tp_sup1_def = Netomox::DSL::TermPoint.new(parent.call('nd1'), 'tpX') do
        support %w[foo bar hoge]
      end
      tp_sup2_def = Netomox::DSL::TermPoint.new(parent.call('nd2'), 'tpX') do
        support %w[foo bar baz]
        support %w[foo bar hoge]
      end
      tp_sup2_changed_def = Netomox::DSL::TermPoint.new(parent.call('nd2c'), 'tpX') do
        support %w[foo bar baz]
        support %w[foo bar changed]
      end
      @tp_sup0 = Netomox::Topology::TermPoint.new(tp_sup0_def.topo_data, '')
      @tp_sup1 = Netomox::Topology::TermPoint.new(tp_sup1_def.topo_data, '')
      @tp_sup2 = Netomox::Topology::TermPoint.new(tp_sup2_def.topo_data, '')
      @tp_sup2_changed = Netomox::Topology::TermPoint.new(tp_sup2_changed_def.topo_data, '')
    end

    it 'kept tp supports' do
      d_tp = @tp_sup1.diff(@tp_sup1.dup)
      expect(d_tp.diff_state.detect).to eq :kept
      list = d_tp.supports.map { |s| s.diff_state.detect }
      expect(list.sort).to eq %i[kept]
    end

    context '0 to N, N to 0' do
      it 'added tp support (0 -> 1)' do
        d_tp = @tp_sup0.diff(@tp_sup1)
        expect(d_tp.diff_state.detect).to eq :changed
        list = d_tp.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[added]
      end

      it 'deleted tp support (1 -> 0)' do
        d_tp = @tp_sup1.diff(@tp_sup0)
        expect(d_tp.diff_state.detect).to eq :changed
        list = d_tp.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[deleted]
      end
    end

    context 'N to M, M to N' do
      it 'added to support (1 -> 2)' do
        d_tp = @tp_sup1.diff(@tp_sup2)
        expect(d_tp.diff_state.detect).to eq :changed
        list = d_tp.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[added kept]
      end

      it 'deleted tp support (2 -> 1)' do
        d_tp = @tp_sup2.diff(@tp_sup1)
        expect(d_tp.diff_state.detect).to eq :changed
        list = d_tp.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[deleted kept]
      end
    end

    it 'changed support tp' do
      d_tp = @tp_sup2.diff(@tp_sup2_changed)
      expect(d_tp.diff_state.detect).to eq :changed
      list = d_tp.supports.map { |s| s.diff_state.detect }
      expect(list.sort).to eq %i[added deleted kept]
    end
  end
end
