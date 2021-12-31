# frozen_string_literal: true

RSpec.describe 'read diff_state from json', :diff do
  context 'read network diff' do
    before do
      src_nws_def = Netomox::DSL::Networks.new do
        network 'nw1'
        network 'nw2'
      end
      dst_nws_def = Netomox::DSL::Networks.new do
        network 'nw2'
        network 'nw3'
      end
      src_nws = Netomox::Topology::Networks.new(src_nws_def.topo_data)
      dst_nws = Netomox::Topology::Networks.new(dst_nws_def.topo_data)
      diff_nws_def = src_nws.diff(dst_nws)
      diff_nws_json_str = JSON.pretty_generate(diff_nws_def.to_data)
      @diff_nws = Netomox::Topology::Networks.new(JSON.parse(diff_nws_json_str))
    end

    it 'networks is changed' do
      expect(@diff_nws.diff_state.detect).to eq :changed
    end

    it 'network nw1 is deleted' do
      expect(@diff_nws.find_network('nw1').diff_state.detect).to eq :deleted
    end

    it 'network nw2 is kept' do
      expect(@diff_nws.find_network('nw2').diff_state.detect).to eq :kept
    end

    it 'network nw3 is added' do
      expect(@diff_nws.find_network('nw3').diff_state.detect).to eq :added
    end
  end

  context 'read node diff' do
    before do
      src_nws_def = Netomox::DSL::Networks.new do
        network 'nw1' do
          node 'node1'
          node 'node2'
        end
      end
      dst_nws_def = Netomox::DSL::Networks.new do
        network 'nw1' do
          node 'node2'
          node 'node3'
        end
      end
      src_nws = Netomox::Topology::Networks.new(src_nws_def.topo_data)
      dst_nws = Netomox::Topology::Networks.new(dst_nws_def.topo_data)
      diff_nws_def = src_nws.diff(dst_nws)
      diff_nws_json_str = JSON.pretty_generate(diff_nws_def.to_data)
      diff_nws = Netomox::Topology::Networks.new(JSON.parse(diff_nws_json_str))
      @diff_nw1 = diff_nws.find_network('nw1')
    end

    it 'network nw1 is changed' do
      expect(@diff_nw1.diff_state.detect).to eq :changed
    end

    it 'node node1 is deleted' do
      expect(@diff_nw1.find_node_by_name('node1').diff_state.detect).to eq :deleted
    end

    it 'node node2 is kept' do
      expect(@diff_nw1.find_node_by_name('node2').diff_state.detect).to eq :kept
    end

    it 'node node3 is deleted' do
      expect(@diff_nw1.find_node_by_name('node3').diff_state.detect).to eq :added
    end
  end

  context 'read term-point diff' do
    before do
      src_nws_def = Netomox::DSL::Networks.new do
        network 'nw1' do
          node 'node1' do
            term_point 'tp1'
            term_point 'tp2'
          end
        end
      end
      dst_nws_def = Netomox::DSL::Networks.new do
        network 'nw1' do
          node 'node1' do
            term_point 'tp2'
            term_point 'tp3'
          end
        end
      end
      src_nws = Netomox::Topology::Networks.new(src_nws_def.topo_data)
      dst_nws = Netomox::Topology::Networks.new(dst_nws_def.topo_data)
      diff_nws_def = src_nws.diff(dst_nws)
      diff_nws_json_str = JSON.pretty_generate(diff_nws_def.to_data)
      diff_nws = Netomox::Topology::Networks.new(JSON.parse(diff_nws_json_str))
      diff_nw1 = diff_nws.find_network('nw1')
      @diff_node1 = diff_nw1.find_node_by_name('node1')
    end

    it 'node node1 is changed' do
      expect(@diff_node1.diff_state.detect).to eq :changed
    end

    it 'term-point tp1 is deleted' do
      expect(@diff_node1.find_tp_by_name('tp1').diff_state.detect).to eq :deleted
    end

    it 'term-point tp2 is kept' do
      expect(@diff_node1.find_tp_by_name('tp2').diff_state.detect).to eq :kept
    end

    it 'term-point tp3 is deleted' do
      expect(@diff_node1.find_tp_by_name('tp3').diff_state.detect).to eq :added
    end
  end

  context 'read link diff' do
    before do
      src_nws_def = Netomox::DSL::Networks.new do
        network 'nw1' do
          node 'node1' do
            term_point 'tp1'
            term_point 'tp2'
          end
          node 'node2' do
            term_point 'tp1'
            term_point 'tp2'
          end
          bdlink %w[node1 tp1 node2 tp1]
          bdlink %w[node1 tp2 node2 tp2]
        end
      end
      dst_nws_def = Netomox::DSL::Networks.new do
        network 'nw1' do
          node 'node1' do
            term_point 'tp2'
            term_point 'tp3'
          end
          node 'node2' do
            term_point 'tp2'
            term_point 'tp3'
          end
          bdlink %w[node1 tp2 node2 tp2]
          bdlink %w[node1 tp3 node2 tp3]
        end
      end
      src_nws = Netomox::Topology::Networks.new(src_nws_def.topo_data)
      dst_nws = Netomox::Topology::Networks.new(dst_nws_def.topo_data)
      diff_nws_def = src_nws.diff(dst_nws)
      diff_nws_json_str = JSON.pretty_generate(diff_nws_def.to_data)
      diff_nws = Netomox::Topology::Networks.new(JSON.parse(diff_nws_json_str))
      @diff_nw1 = diff_nws.find_network('nw1')
    end

    it 'network nw1 is changed' do
      expect(@diff_nw1.diff_state.detect).to eq :changed
    end

    it 'link node1/tp1 <=> node2/tp1 is deleted' do
      expect(@diff_nw1.find_link_by_name(%w[node1 tp1 node2 tp1].join(',')).diff_state.detect).to eq :deleted
      expect(@diff_nw1.find_link_by_name(%w[node2 tp1 node1 tp1].join(',')).diff_state.detect).to eq :deleted
    end

    it 'link node1/tp2 <=> node2/tp2 is kept' do
      expect(@diff_nw1.find_link_by_name(%w[node1 tp2 node2 tp2].join(',')).diff_state.detect).to eq :kept
      expect(@diff_nw1.find_link_by_name(%w[node2 tp2 node1 tp2].join(',')).diff_state.detect).to eq :kept
    end

    it 'link node1/tp3 <=> node2/tp3 is added' do
      expect(@diff_nw1.find_link_by_name(%w[node1 tp3 node2 tp3].join(',')).diff_state.detect).to eq :added
      expect(@diff_nw1.find_link_by_name(%w[node2 tp3 node1 tp3].join(',')).diff_state.detect).to eq :added
    end
  end
end
