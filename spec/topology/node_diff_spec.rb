RSpec.describe 'node diff (supporting-node list)', :diff, :node do
  context 'when node literal attribute changed' do
    before do
      node_def = Netomox::DSL::Node.new('nodeX', '')
      @node = Netomox::Topology::Node.new(node_def.topo_data, 'nwX')
      @node_kept = Netomox::Topology::Node.new(node_def.topo_data, 'nwX')
      @node_changed = Netomox::Topology::Node.new(node_def.topo_data, 'nwY')
    end

    it 'kept node info' do
      d_node = @node.diff(@node_kept)
      expect(d_node.diff_state.detect).to eq :kept
    end

    it 'changed by parent path' do
      d_node = @node.diff(@node_changed)
      expect(d_node.diff_state.detect).to eq :changed
    end
  end

  context 'when support node list changed', :support do
    before do
      node_sup0_def = Netomox::DSL::Node.new('nodeX', '')
      node_sup1_def = Netomox::DSL::Node.new('nodeX', '') do
        support %w[nw1 node1]
      end
      node_sup2_def = Netomox::DSL::Node.new('nodeX', '') do
        support %w[nw1 node1]
        support %w[nw1 node2]
      end
      node_sup2_changed_def = Netomox::DSL::Node.new('nodeX', '') do
        support %w[nw1 node1]
        support %w[nw1 node2aa]
      end

      @node_sup0 = Netomox::Topology::Node.new(node_sup0_def.topo_data, '')
      @node_sup1 = Netomox::Topology::Node.new(node_sup1_def.topo_data, '')
      @node_sup2 = Netomox::Topology::Node.new(node_sup2_def.topo_data, '')
      @node_sup2_changed = Netomox::Topology::Node.new(node_sup2_changed_def.topo_data, '')
    end

    it 'kept node supports' do
      d_node = @node_sup1.diff(@node_sup1.dup)
      expect(d_node.diff_state.detect).to eq :kept
      list = d_node.supports.map { |s| s.diff_state.detect }
      expect(list.sort).to eq %i[kept]
    end

    context '0 to N, N to 0' do
      it 'added tp support (0 -> 1)' do
        d_node = @node_sup0.diff(@node_sup1)
        expect(d_node.diff_state.detect).to eq :changed
        list = d_node.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[added]
      end

      it 'added tp support (1 -> 0)' do
        d_node = @node_sup1.diff(@node_sup0)
        expect(d_node.diff_state.detect).to eq :changed
        list = d_node.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[deleted]
      end
    end

    context 'N to M, M to N' do
      it 'added tp support (1 -> 2)' do
        d_node = @node_sup1.diff(@node_sup2)
        expect(d_node.diff_state.detect).to eq :changed
        list = d_node.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[added kept]
      end

      it 'added tp support (2 -> 1)' do
        d_node = @node_sup2.diff(@node_sup1)
        expect(d_node.diff_state.detect).to eq :changed
        list = d_node.supports.map { |s| s.diff_state.detect }
        expect(list.sort).to eq %i[deleted kept]
      end
    end

    it 'changed support node' do
      d_node = @node_sup2.diff(@node_sup2_changed)
      expect(d_node.diff_state.detect).to eq :changed
      list = d_node.supports.map { |s| s.diff_state.detect }
      expect(list.sort).to eq %i[added deleted kept]
    end
  end
end
