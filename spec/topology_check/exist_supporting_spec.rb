# frozen_string_literal: true

RSpec.describe 'check existence of definition referred as support', :checkup do
  def element_not_found_message(target_type, path)
    "definition referred as supporting #{target_type} support:#{path} is not found."
  end

  def parent_element_not_found_message(parent, target)
    "cannot find #{parent}, parent of #{target}"
  end

  def get_message(result, index)
    result[:messages][index][:message]
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

    it 'finds 1 error' do
      expect(@result[:messages].length).to eq 1
    end

    it 'finds lack of support network definition' do
      expect(get_message(@result, 0)).to eq element_not_found_message('network', 'nw_not_exist')
    end
  end

  context 'supporting node reference' do
    before do
      nws_def = Netomox::DSL::Networks.new do
        network 'nw1' do
          node 'node1' do
            support %w[nw2 node_exist]
            support %w[nw2 node_not_exist]
            support %w[nw3 nw_not_exist]
          end
        end
        network 'nw2' do
          node 'node_exist'
        end
      end
      nws = Netomox::Topology::Networks.new(nws_def.topo_data)
      @result = nws.check_exist_supporting_node
    end

    it 'finds 3 errors' do
      expect(@result[:messages].length).to eq 3
    end

    it 'finds lack of support node definition' do
      expect(get_message(@result, 0)).to eq element_not_found_message('node', 'nw2__node_not_exist')
    end

    it 'finds lack of network ref of support node definition' do
      expect(get_message(@result, 1)).to eq parent_element_not_found_message('network:nw3', 'node:nw_not_exist')
      expect(get_message(@result, 2)).to eq element_not_found_message('node', 'nw3__nw_not_exist')
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
              support %w[nw2 node3 node_not_exist]
              support %w[nw3 node2 nw_not_exist]
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

    it 'finds 5 errors' do
      expect(@result[:messages].length).to eq 5
    end

    it 'finds lack of support tp definition' do
      expect(get_message(@result, 0)).to eq element_not_found_message('tp', 'nw2__node2__tp_not_exist')
    end

    it 'finds lack of node ref of support tp definition' do
      expect(get_message(@result, 1)).to eq parent_element_not_found_message('node:nw2__node3', 'tp:node_not_exist')
      expect(get_message(@result, 2)).to eq element_not_found_message('tp', 'nw2__node3__node_not_exist')
    end

    it 'finds lack of nw ref of support tp definition' do
      expect(get_message(@result, 3)).to eq parent_element_not_found_message('network:nw3', 'node:node2')
      expect(get_message(@result, 4)).to eq element_not_found_message('tp', 'nw3__node2__nw_not_exist')
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
          link %w[node1 tp1 node2 tp1] do
            support 'nw2', 'node3,tp1,node4,tp1' # exists
            support 'nw2', 'node5,tp1,node6,tp1' # not exists
            support 'nw3', 'node3,tp1,node4,tp1' # not exists network
          end
        end
        network 'nw2' do
          node 'node3' do
            term_point 'tp1'
          end
          node 'node4' do
            term_point 'tp1'
          end
          link %w[node3 tp1 node4 tp1]
        end
      end
      nws = Netomox::Topology::Networks.new(nws_def.topo_data)
      @result = nws.check_exist_supporting_link
    end

    it 'finds 3 errors' do
      expect(@result[:messages].length).to eq 3
    end

    it 'finds lack of support link definition' do
      expect(get_message(@result, 0)).to eq element_not_found_message('link', 'nw2__node5,tp1,node6,tp1')
    end

    it 'finds lack of network ref of support node definition' do
      expect(get_message(@result, 1)).to eq parent_element_not_found_message('nw:nw3', 'link:node3,tp1,node4,tp1')
      expect(get_message(@result, 2)).to eq element_not_found_message('link', 'nw3__node3,tp1,node4,tp1')
    end
  end
end
