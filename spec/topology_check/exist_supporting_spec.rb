RSpec.describe 'check existence of definition referred as support', :checkup do
  def message(object_type, path)
    "definition referred as supporting #{object_type} support:#{path} is not found."
  end

  context 'supporting network reference' do
    before do
      nws_def = Netomox::DSL::Networks.new do
        network 'nw1' do
          support 'nw_exist'
          support 'nw_not_exist'
        end
        network 'nw_exist'
      end
      nws = Netomox::Topology::Networks.new(nws_def.topo_data)
      @result = nws.check_exist_supporting_network
    end

    it 'finds lack of support network definition' do
      expect(@result[:messages].length).to eq 1
      expect(@result[:messages][0][:message]).to eq message('network', 'nw_not_exist')
    end
  end

  context 'supporting node reference' do
    before do
      nws_def = Netomox::DSL::Networks.new do
        network 'nw1' do
          node 'node1' do
            support %w[nw2 node_exist]
            support %w[nw2 node_not_exist]
          end
        end
        network 'nw2' do
          node 'node_exist'
        end
      end
      nws = Netomox::Topology::Networks.new(nws_def.topo_data)
      @result = nws.check_exist_supporting_node
    end

    it 'finds lack of support node definition' do
      expect(@result[:messages].length).to eq 1
      expect(@result[:messages][0][:message]).to eq message('node', 'nw2/node_not_exist')
    end
  end

  context 'supporting tp reference' do
    before do
      nws_def = Netomox::DSL::Networks.new do
        network 'nw1' do
          node 'node1' do
            term_point 'tp1' do
              support %w[nw2 node2 tp_exist]
              support %w[nw2 node2 tp_not_exist]
            end
          end
        end
        network 'nw2' do
          node 'node2' do
            term_point 'tp_exist'
          end
        end
      end
      nws = Netomox::Topology::Networks.new(nws_def.topo_data)
      @result = nws.check_exist_supporting_tp
    end

    it 'finds lack of support tp definition' do
      expect(@result[:messages].length).to eq 1
      expect(@result[:messages][0][:message]).to eq message('tp', 'nw2/node2/tp_not_exist')
    end
  end

  context 'supporting link reference' do
    before do
      nws_def = Netomox::DSL::Networks.new do
        network 'nw1' do
          node 'node1' do
            term_point 'tp1'
          end
          node 'node2' do
            term_point 'tp1'
          end
          link *%w[node1 tp1 node2 tp1] do
            support *%w[nw2 node3,tp1,node4,tp1] # exists
            support *%w[nw2 node5,tp1,node6,tp1] # not exists
          end
        end
        network 'nw2' do
          node 'node3' do
            term_point 'tp1'
          end
          node 'node4' do
            term_point 'tp1'
          end
          link *%w[node3 tp1 node4 tp1]
        end
      end
      nws = Netomox::Topology::Networks.new(nws_def.topo_data)
      @result = nws.check_exist_supporting_link
    end

    it 'finds lack of support link definition' do
      expect(@result[:messages].length).to eq 1
      expect(@result[:messages][0][:message]).to eq message('link', 'nw2/node5,tp1,node6,tp1')
    end
  end
end
