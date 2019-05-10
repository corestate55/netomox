RSpec.describe 'node sorting for network', :dsl, :network, :node do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'test-layer' do
        node 'node_cc'
        node 'node_aa'
        node 'node_bb' do
          term_point 'tp_3'
          term_point 'tp_1'
          term_point 'tp_2'
        end
      end
    end
    @test_layer = nws.network('test-layer')
  end

  it 'sort(destructive) nodes list in network' do
    @test_layer.sort_node_by_name!
    expect_node_seq = %w[node_aa node_bb node_cc]
    expect(@test_layer.nodes.map(&:name)).to eq expect_node_seq
  end

  it 'sort(overwrite) term_point list in node' do
    node = @test_layer.node('node_bb')
    node.sort_tp_by_name!
    expect_tp_seq = %w[tp_1 tp_2 tp_3]
    expect(node.term_points.map(&:name)).to eq expect_tp_seq
  end
end
