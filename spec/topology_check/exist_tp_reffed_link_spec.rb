# frozen_string_literal: true

RSpec.describe 'check existence of tp refered in link src/dst', :checkup do
  before do
    nws_def = Netomox::DSL::Networks.new do
      network 'nw1' do
        node 'node1' do
          term_point 'p1'
          term_point 'p2'
        end
        node 'node2' do
          term_point 'p1'
          term_point 'p2'
        end
        # link (correct)
        link 'node1', 'p1', 'node2', 'p1'
        # link (wrong: source tp not found
        link 'node1', 'X1', 'node2', 'p1'
        # link (wrong: dest tp not found
        link 'node1', 'p1', 'node2', 'Y1'
      end
    end
    nws = Netomox::Topology::Networks.new(nws_def.topo_data)
    @result = nws.check_exist_link_tp
  end

  it 'found source tp ref is not exists' do
    msg = @result[:messages][0]
    expect(msg[:path]).to eq 'nw1__node1,X1,node2,p1'
    expect(msg[:message]).to eq 'link source path:nw1__node1__X1 is not found in link:nw1__node1,X1,node2,p1'
  end

  it 'found destination tp ref is not exists' do
    msg = @result[:messages][1]
    expect(msg[:path]).to eq 'nw1__node1,p1,node2,Y1'
    expect(msg[:message]).to eq 'link destination path:nw1__node2__Y1 is not found in link:nw1__node1,p1,node2,Y1'
  end
end
