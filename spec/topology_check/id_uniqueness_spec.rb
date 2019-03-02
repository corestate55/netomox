RSpec.describe 'check id uniqueness', :checkup do
  def message(id_type, id)
    %(found duplicate '#{id_type}_id': ["#{id}"])
  end

  before do
    # Notice:
    #   Netomox::DSL::Networks#network,
    #   Netomox::DSL::Network##node, #link and
    #   Netomox::DSL::Node#term_point
    #   checks network_id already exists.
    #   So, cannot append object which has same name(id).
    module Netomox
      module DSL
        class Network
          attr_accessor :nodes
          attr_accessor :links
        end
        class Node
          attr_accessor :term_points
        end
      end
    end
  end

  context 'exists duplicated network' do
    before do
      nws_def = Netomox::DSL::Networks.new do
        network 'nw1'
        network 'nw2'
      end
      nw2dup_def = Netomox::DSL::Network.new(nws_def, 'nw2')
      nws_def.networks.push(nw2dup_def) # force push
      nws = Netomox::Topology::Networks.new(nws_def.topo_data)
      @result = nws.check_id_uniqueness
    end

    it 'finds duplicated network' do
      expect(@result[:messages].length).to eq 1
      expect(@result[:messages][0][:message]).to eq message('network', 'nw2')
    end
  end

  context 'exists duplicated node' do
    before do
      nws_def = Netomox::DSL::Networks.new
      nw1_def = Netomox::DSL::Network.new(nws_def, 'nw1') do
        node 'node1'
        node 'node2'
      end
      node2dup_def = Netomox::DSL::Node.new(nw1_def, 'node2')
      nw1_def.nodes.push(node2dup_def)
      nws_def.networks.push(nw1_def)
      nws = Netomox::Topology::Networks.new(nws_def.topo_data)
      @result = nws.check_id_uniqueness
    end

    it 'finds duplicated node' do
      expect(@result[:messages].length).to eq 1
      expect(@result[:messages][0][:message]).to eq message('node', 'node2')
    end
  end

  context 'exists duplicated tp' do
    before do
      nws_def = Netomox::DSL::Networks.new
      nw1_def = Netomox::DSL::Network.new(nws_def, 'nw1')
      nws_def.networks.push(nw1_def)
      node1_def = Netomox::DSL::Node.new(nw1_def, 'node1') do
        term_point 'tp1'
        term_point 'tp2'
      end
      tp2dup_def = Netomox::DSL::TermPoint.new(node1_def, 'tp2')
      node1_def.term_points.push(tp2dup_def)
      nw1_def.nodes.push(node1_def)
      nws = Netomox::Topology::Networks.new(nws_def.topo_data)
      @result = nws.check_id_uniqueness
    end

    it 'finds duplicated tp' do
      expect(@result[:messages].length).to eq 1
      expect(@result[:messages][0][:message]).to eq message('tp', 'tp2')
    end
  end

  context 'exists duplicated link' do
    before do
      nws_def = Netomox::DSL::Networks.new
      nw1_def = Netomox::DSL::Network.new(nws_def, 'nw1') do
        link 'node1', 'tp1', 'node2', 'tp1' # link1
        link 'node1', 'tp2', 'node2', 'tp2' # link2
      end
      link2dup_def = Netomox::DSL::Link.new(nw1_def, 'node1', 'tp2', 'node2', 'tp2')
      nw1_def.links.push(link2dup_def)
      nws_def.networks.push(nw1_def)
      nws = Netomox::Topology::Networks.new(nws_def.topo_data)
      @result = nws.check_id_uniqueness
    end

    it 'finds duplicated link' do
      expect(@result[:messages].length).to eq 1
      expect(@result[:messages][0][:message]).to eq message('link', 'node1,tp2,node2,tp2')
    end
  end
end
