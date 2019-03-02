RSpec.describe 'check term point ref count', :checkup do
  def find_message(path)
=begin
{
  :checkup=>"check link reference count of terminal-point",
  :messages=>[
    {:severity=>:warn, :path=>"nw1/node1/tp2", :message=>"irregular ref_count:1"},
    {:severity=>:warn, :path=>"nw1/node1/tp3", :message=>"irregular ref_count:1"},
    {:severity=>:warn, :path=>"nw1/node2/tp3", :message=>"irregular ref_count:0"}
  ]
}
=end
    res = @result[:messages].find { |r| r[:path] == path }
    res ? res[:message] : ''
  end

  before do
=begin
              (n): ref_count
         node1                      node2
       (2) tp1 <------------------- tp1 (2) : normal bid-directional link
               ------------------->


       (1) tp2 -------------------> tp2 (2)
                       /-----------         : mistake!
                      /
       (1) tp3 <-----/              tp3 (0)
=end
    nws_def = Netomox::DSL::Networks.new do
      network 'nw1' do
        node 'node1' do
          term_point 'tp1'
          term_point 'tp2'
          term_point 'tp3'
        end
        node 'node2' do
          term_point 'tp1'
          term_point 'tp2'
          term_point 'tp3'
        end
        # normal bi-directional link
        bdlink *%w[node1 tp1 node2 tp1]
        # fail to create node1/tp2-node2/tp2 link
        link *%w[node1 tp2 node2 tp2]
        link *%w[node2 tp2 node1 tp3]
      end
    end
    nws = Netomox::Topology::Networks.new(nws_def.topo_data)
    @result = nws.check_tp_ref_count
  end

  it 'finds irregular ref count at node1/tp2' do
    expect(find_message('nw1/node1/tp2')).to eq 'irregular ref_count:1'
  end

  it 'finds irregular ref count at node1/tp3' do
    expect(find_message('nw1/node1/tp3')).to eq 'irregular ref_count:1'
  end

  it 'finds irregular ref count at node2/tp3' do
    expect(find_message('nw1/node2/tp3')).to eq 'irregular ref_count:0'
  end
end
