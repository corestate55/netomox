RSpec.describe 'networks dsl', :dsl, :networks, :network do
  before do
    @nws_key = "#{Netomox::DSL::NS_NW}:networks"
    @link_key = "#{Netomox::DSL::NS_TOPO}:link"
  end

  it 'generate single network list (networks)' do
    nws = Netomox::DSL::Networks.new
    nws_data = { @nws_key => { 'network' => [] } }
    expect(nws.topo_data).to eq nws_data
  end

  it 'generate network list that has network' do
    nws = Netomox::DSL::Networks.new do
      network 'nw1'
    end
    nws_data = {
      @nws_key => {
        'network' => [
          'network-id' => 'nw1',
          'network-types' => {},
          'node' => [],
          @link_key => []
        ]
      }
    }
    expect(nws.topo_data).to eq nws_data
  end
end
