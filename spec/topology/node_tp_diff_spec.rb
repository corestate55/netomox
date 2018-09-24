RSpec.describe 'node diff (termination point list)', :diff, :node, :tp do
  context 'when term point list changed' do
    before do
      parent = lambda do |name|
        nws = Netomox::DSL::Networks.new
        Netomox::DSL::Network.new(nws, name)
      end
      node_tp0_def = Netomox::DSL::Node.new(parent.call('nw0'), 'nodeX')
      node_tp1_def = Netomox::DSL::Node.new(parent.call('nw1'), 'nodeX') do
        term_point 'tp1'
      end
      node_tp2_def = Netomox::DSL::Node.new(parent.call('nw2'), 'nodeX') do
        term_point 'tp1'
        term_point 'tp2'
      end
      node_tp2_changed_def = Netomox::DSL::Node.new(parent.call('nw2c'), 'nodeX') do
        term_point 'tp1'
        term_point 'tp2xx'
      end
      @node_tp0 = Netomox::Topology::Node.new(node_tp0_def.topo_data, 'nwX')
      @node_tp1 = Netomox::Topology::Node.new(node_tp1_def.topo_data, 'nwX')
      @node_tp2 = Netomox::Topology::Node.new(node_tp2_def.topo_data, 'nwX')
      @node_tp2_changed = Netomox::Topology::Node.new(node_tp2_changed_def.topo_data, 'nwX')
    end

    context '0 to N, N to 0' do
      it 'added node tp (0 -> 1)' do
        d_node = @node_tp0.diff(@node_tp1)
        expect(d_node.diff_state.detect).to eq :changed
        list = d_node.termination_points.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[added]
      end

      it 'deleted node tp (1 -> 0)' do
        d_node = @node_tp1.diff(@node_tp0)
        expect(d_node.diff_state.detect).to eq :changed
        list = d_node.termination_points.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[deleted]
      end
    end

    context 'N to M, M to N' do
      it 'added node tp (1 -> 2)' do
        d_node = @node_tp1.diff(@node_tp2)
        expect(d_node.diff_state.detect).to eq :changed
        list = d_node.termination_points.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[added kept]
      end

      it 'added node tp (1 -> 2)' do
        d_node = @node_tp2.diff(@node_tp1)
        expect(d_node.diff_state.detect).to eq :changed
        list = d_node.termination_points.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[deleted kept]
      end
    end

    it 'changed node tp' do
      d_node = @node_tp2.diff(@node_tp2_changed)
      expect(d_node.diff_state.detect).to eq :changed
      list = d_node.termination_points.map { |t| t.diff_state.detect }
      expect(list.sort).to eq %i[added deleted kept]
    end
  end
end
