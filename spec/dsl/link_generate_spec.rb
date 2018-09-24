RSpec.describe 'methods to generate link from/to node/tp', :dsl, :link do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'nwX' do
        node 'nodeX' do
          term_point 'tpA'
        end
        node 'nodeY' do
          term_point 'tpB'
        end
      end
    end
    @nw = nws.network('nwX')
  end

  context 'Node to node/tp' do
    before do
      @nw.register do
        node('nodeX').bdlink_to(node('nodeY'))
      end
    end

    it 'generate new tp in nodeX/Y' do
      expect(@nw.node('nodeX').find_term_point('p0').name).to eq 'p0'
      expect(@nw.node('nodeY').find_term_point('p0').name).to eq 'p0'
    end

    it 'generate bi-directional link from/to node' do
      link1_spec = %w[nodeX p0 nodeY p0]
      name = link1_spec.join(',')
      expect(@nw.find_link(name)).not_to eq nil
      link2_spec = %w[nodeY p0 nodeX p0]
      name = link2_spec.join(',')
      expect(@nw.find_link(name)).not_to eq nil
    end

    it 'generate bi-directional link from node to tp' do
      @nw.register do
        node('nodeX').bdlink_to(node('nodeY').term_point('tpB'))
      end
      link1_spec = %w[nodeX p1 nodeY tpB]
      name = link1_spec.join(',')
      expect(@nw.find_link(name)).not_to eq nil
      link2_spec = %w[nodeY tpB nodeX p1]
      name = link2_spec.join(',')
      expect(@nw.find_link(name)).not_to eq nil
    end
  end

  context 'TermPoint to node/tp' do
    it 'generate bi-directional link from/to tp' do
      @nw.register do
        node('nodeX').bdlink_to(node('nodeY'))
        node('nodeX').bdlink_to(node('nodeY').term_point('tpB'))
        node('nodeX').term_point('tpA').bdlink_to(node('nodeY'))
      end
      link1_spec = %w[nodeX tpA nodeY p1]
      name = link1_spec.join(',')
      expect(@nw.find_link(name)).not_to eq nil
      link2_spec = %w[nodeY p1 nodeX tpA]
      name = link2_spec.join(',')
      expect(@nw.find_link(name)).not_to eq nil
    end

    it 'generate bi-directional link from tp to node' do
      @nw.register do
        node('nodeX').term_point('tpA').bdlink_to(node('nodeY').term_point('tpB'))
      end
      link1_spec = %w[nodeX tpA nodeY tpB]
      name = link1_spec.join(',')
      expect(@nw.find_link(name)).not_to eq nil
      link2_spec = %w[nodeY tpB nodeX tpA]
      name = link2_spec.join(',')
      expect(@nw.find_link(name)).not_to eq nil
    end
  end
end
