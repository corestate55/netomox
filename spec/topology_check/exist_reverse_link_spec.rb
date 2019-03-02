RSpec.describe 'check existence of reverse link', :checkup do
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
        # bi-directionl
        link *%w[node1 tp1 node2 tp1]
        link *%w[node2 tp1 node1 tp1]
        # uni-directional
        link *%w[node1 tp2 node2 tp2]
      end
    end
    nws = Netomox::Topology::Networks.new(nws_def.topo_data)
    @result = nws.check_exist_reverse_link
  end

  it 'finds unidirectional link' do
    expect(@result[:messages].length).to eq 1
    msg = @result[:messages][0]
    expect(msg[:path]).to eq 'nw1/node1,tp2,node2,tp2'
    expect(msg[:message]).to eq 'reverse link of link:node1,tp2,node2,tp2 is not found.'
  end
end
