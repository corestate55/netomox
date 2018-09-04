require_relative '../spec_helper'

describe 'link diff (supporting-node list)', :diff, :link do
  context 'when link literal attribute changed' do
    before do
      link_spec = %w[node1 tp1 node2 tp2]
      link_def = NWTopoDSL::Link.new(*link_spec, '')
      @link = TopoChecker::Link.new(link_def.topo_data, 'nwX')
      @link_kept = TopoChecker::Link.new(link_def.topo_data, 'nwX')
      @link_changed = TopoChecker::Link.new(link_def.topo_data, 'nwY')
    end

    it 'kept tp info' do
      d_link = @link.diff(@link_kept)
      expect(d_link.diff_state.detect).to eq :kept
    end

    it 'changed by parent path' do
      d_link = @link.diff(@link_changed)
      expect(d_link.diff_state.detect).to eq :changed
    end
  end

  context 'when support link list changed', :support do
    before do
      link_spec = %w[node1 tp1 node2 tp2]
      link_sup0_def = NWTopoDSL::Link.new(*link_spec, '')
      link_sup1_def = NWTopoDSL::Link.new(*link_spec, '') do
        support %w[nw1 link1]
      end
      link_sup2_def = NWTopoDSL::Link.new(*link_spec, '') do
        support %w[nw1 link1]
        support %w[nw1 link2]
      end
      link_sup2_changed_def = NWTopoDSL::Link.new(*link_spec, '') do
        support %w[nw1 link1]
        support %w[nw1 link2aa]
      end

      @link_sup0 = TopoChecker::Link.new(link_sup0_def.topo_data, '')
      @link_sup1 = TopoChecker::Link.new(link_sup1_def.topo_data, '')
      @link_sup2 = TopoChecker::Link.new(link_sup2_def.topo_data, '')
      @link_sup2_changed = TopoChecker::Link.new(link_sup2_changed_def.topo_data, '')
    end
    it 'kept link supports' do
      d_link = @link_sup1.diff(@link_sup1.dup)
      expect(d_link.diff_state.detect).to eq :kept
      list = d_link.supports.map { |s| s.diff_state.detect }
      expect(list.sort).to eq %i[kept]
    end

    context '0 to N, N to 0' do
      it 'added tp support (0 -> 1)' do
        d_link = @link_sup0.diff(@link_sup1)
        expect(d_link.diff_state.detect).to eq :changed
        list = d_link.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[added]
      end

      it 'added tp support (1 -> 0)' do
        d_link = @link_sup1.diff(@link_sup0)
        expect(d_link.diff_state.detect).to eq :changed
        list = d_link.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[deleted]
      end
    end

    context 'N to M, M to N' do
      it 'added tp support (1 -> 2)' do
        d_link = @link_sup1.diff(@link_sup2)
        expect(d_link.diff_state.detect).to eq :changed
        list = d_link.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[added kept]
      end

      it 'added tp support (2 -> 1)' do
        d_link = @link_sup2.diff(@link_sup1)
        expect(d_link.diff_state.detect).to eq :changed
        list = d_link.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[deleted kept]
      end
    end

    it 'changed support link' do
      d_link = @link_sup2.diff(@link_sup2_changed)
      expect(d_link.diff_state.detect).to eq :changed
      list = d_link.supports.map { |s| s.diff_state.detect }
      expect(list.sort).to eq %i[added deleted kept]
    end
  end
end
