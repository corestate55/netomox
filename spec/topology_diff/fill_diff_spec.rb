# frozen_string_literal: true

RSpec.describe 'diff_state filling', :diff do
  context 'when added new object' do
    before do
      nws1_def = Netomox::DSL::Networks.new
      nws2_def = Netomox::DSL::Networks.new do
        network 'nw1' do
          type Netomox::NWTYPE_L2
          attribute(name: 'nwX', flags: %w[foo bar baz])
          support 'hoge_nw'
          support 'fuga_nw'
          node 'node1' do
            attribute(name: 'node1', mgmt_vid: 10, mgmt_addrs: %w[192.168.1.10])
            support %w[hoge_nw nodeX]
            support %w[hoge_nw nodeY]
            term_point 'tp1' do
              access_vlan_a = {
                port_vlan_id: 10,
                vlan_id_names: [
                  { id: 10, name: 'Seg.A' },
                  { id: 20, name: 'Seg.B' }
                ]
              }
              attribute(access_vlan_a)
              support %w[fuga_nw nodeX tp1]
              support %w[fuga_nw nodeY tp2]
            end
          end
          bdlink %w[node1 tp1 node2 tp2] do
            attribute(name: 'linkX', flags: [], rate: 1000, delay: 10, srlg: '')
            support %w[hoge_nw nodeX,tp1,nodeY,tp2]
            support %w[hoge_nw nodeP,tp1,nodeQ,tp1]
          end
        end
      end
      nws1 = Netomox::Topology::Networks.new(nws1_def.topo_data)
      nws2 = Netomox::Topology::Networks.new(nws2_def.topo_data)
      @d_nws = nws1.diff(nws2)
    end

    context 'networks view' do
      it 'was changed by adding nw1' do
        expect(@d_nws.diff_state.detect).to eq :changed
      end
    end

    context 'network view' do
      it 'adds network:nw1' do
        nw = @d_nws.find_network('nw1')
        expect(nw.diff_state.detect).to eq :added
      end

      it 'fills network attribute' do
        attr = @d_nws.find_network('nw1').attribute
        expect(attr.diff_state.detect).to eq :added
      end

      it 'fills supporting networks' do
        supports = @d_nws.find_network('nw1').supports.map do |support|
          support.diff_state.detect
        end
        expect(supports.all?(:added)).to eq true
      end
    end

    context 'node view' do
      it 'filled to add network as added' do
        node = @d_nws.find_node('nw1', 'node1')
        expect(node.diff_state.detect).to eq :added
      end

      it 'filled attribute as added' do
        node = @d_nws.find_node('nw1', 'node1')
        attr = node.attribute
        expect(attr.diff_state.detect).to eq :added
      end

      it 'filled supporting nodes' do
        node = @d_nws.find_node('nw1', 'node1')
        supports = node.supports.map do |support|
          support.diff_state.detect
        end
        expect(supports.all?(:added)).to eq true
      end
    end

    context 'link view' do
      it 'filled to add network as added' do
        link = @d_nws.find_link('nw1', %w[node1 tp1 node2 tp2].join(','))
        expect(link.diff_state.detect).to eq :added
      end

      it 'filled source as added' do
        link = @d_nws.find_link('nw1', %w[node1 tp1 node2 tp2].join(','))
        src = link.source
        expect(src.diff_state.detect).to eq :added
      end

      it 'filled destination as added' do
        link = @d_nws.find_link('nw1', %w[node1 tp1 node2 tp2].join(','))
        dst = link.destination
        expect(dst.diff_state.detect).to eq :added
      end

      it 'filled attribute as added' do
        link = @d_nws.find_link('nw1', %w[node1 tp1 node2 tp2].join(','))
        attr = link.attribute
        expect(attr.diff_state.detect).to eq :added
      end

      it 'filled supporting nodes' do
        link = @d_nws.find_link('nw1', %w[node1 tp1 node2 tp2].join(','))
        supports = link.supports.map do |support|
          support.diff_state.detect
        end
        expect(supports.all?(:added)).to eq true
      end
    end

    context 'term point view' do
      it 'filled to add network as added' do
        tp = @d_nws.find_tp('nw1', 'node1', 'tp1')
        expect(tp.diff_state.detect).to eq :added
      end

      it 'filled attribute as added' do
        tp = @d_nws.find_tp('nw1', 'node1', 'tp1')
        attr = tp.attribute
        expect(attr.diff_state.detect).to eq :added
      end

      it 'filled supporting nodes' do
        tp = @d_nws.find_tp('nw1', 'node1', 'tp1')
        supports = tp.supports.map do |support|
          support.diff_state.detect
        end
        expect(supports.all?(:added)).to eq true
      end
    end
  end
end
