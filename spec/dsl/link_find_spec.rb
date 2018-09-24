RSpec.describe 'methods to find link from/to node/tp', :dsl, :link do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'nwX' do
        node_x = node 'nodeX' do
          term_point 'tpA'
        end
        node_y = node 'nodeY' do
          term_point 'tpB'
        end
        node_x.bdlink_to(node_y)
        node_x.bdlink_to(node_y.tp('tpB'))
        node_x.tp('tpA').bdlink_to(node_y)
        node_x.tp('tpA').bdlink_to(node_y.tp('tpB'))
      end
    end
    @nw = nws.network('nwX')
    @node_x = @nw.node('nodeX')
    @node_y = @nw.node('nodeY')
  end

  context 'Network#find_links_between' do
    it 'returns 1 link: nodeX,p0,nodeY,p0' do
      opts = {
        src_node_name: 'nodeX', src_tp_name: 'p0',
        dst_node_name: 'nodeY', dst_tp_name: 'p0'
      }
      links = @nw.find_links_between(opts)
      expect(links.length).to eq 1
    end

    it 'returns 2 links: from nodeX/tpA to nodeY' do
      opts = {
        src_node_name: 'nodeX', src_tp_name: 'tpA',
        dst_node_name: 'nodeY'
      }
      links = @nw.find_links_between(opts)
      expect(links.length).to eq 2
    end

    it 'returns 2 links: from nodeX to nodeY/tpB' do
      opts = {
        src_node_name: 'nodeX',
        dst_node_name: 'nodeY', dst_tp_name: 'tpB'
      }
      links = @nw.find_links_between(opts)
      expect(links.length).to eq 2
    end

    it 'returns 4 links: from nodeX to nodeY' do
      opts = {
        src_node_name: 'nodeX',
        dst_node_name: 'nodeY'
      }
      links = @nw.find_links_between(opts)
      expect(links.length).to eq 4
    end
  end

  context 'Node#links_between' do
    it 'returns 4 links: from nodeX to nodeY' do
      links = @node_x.links_between(@node_y)
      expect(links.length).to eq 4
    end

    it 'returns 2 links: from nodeX to nodeY/tpB' do
      links = @node_x.links_between(@node_y.find_tp('tpB'))
      expect(links.length).to eq 2
    end
  end

  context 'TermPoint#links_between' do
    it 'returns 2 links: from nodeX/tpA to nodeY' do
      links = @node_x.find_tp('tpA').links_between(@node_y)
      expect(links.length).to eq 2
    end

    it 'returns 1 links: from nodeX/tpA to nodeY/tpB' do
      links = @node_x.find_tp('tpA').links_between(@node_y.find_tp('tpB'))
      expect(links.length).to eq 1
    end
  end
end
