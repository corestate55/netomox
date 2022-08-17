# frozen_string_literal: true

RSpec.describe 'termination point diff with ospf attribute', :diff, :tp, :attr, :ospf_attr do
  before do
    parent = lambda do |name|
      nws = Netomox::DSL::Networks.new do
        network 'ospf' do
          type Netomox::NWTYPE_MDDO_OSPF_AREA
          node name
        end
      end
      nws.network('ospf').node(name)
    end

    attr_timer1 = { hello_interval: 10, dead_interval: 40, retransmission_interval: 5 }
    attr_timer2 = { hello_interval: 5, dead_interval: 40, retransmission_interval: 5 } # change hello
    attr_neighbor1 = { router_id: '192.168.0.1', ip_addr: '172.16.0.1' }
    attr_neighbor2 = { router_id: '192.168.0.2', ip_addr: '172.16.0.1' } # change router_id
    tp_ospf_attr1 = {
      network_type: 'BROADCAST', priority: 10, metric: 1, passive: false,
      timer: attr_timer1, neighbors: [attr_neighbor1]
    }
    tp_ospf_attr2 = { # change network_type
      network_type: 'P2P', priority: 10, metric: 1, passive: false,
      timer: attr_timer1, neighbors: [attr_neighbor1]
    }
    tp_ospf_attr3 = { # change timer
      network_type: 'BROADCAST', priority: 10, metric: 1, passive: false,
      timer: attr_timer2, neighbors: [attr_neighbor1]
    }
    tp_ospf_attr4 = { # change neighbors
      network_type: 'BROADCAST', priority: 10, metric: 1, passive: false,
      timer: attr_timer1, neighbors: [attr_neighbor2]
    }
    tp_ospf_attr5 = { # add neighbors
      network_type: 'BROADCAST', priority: 10, metric: 1, passive: false,
      timer: attr_timer1, neighbors: [attr_neighbor1, attr_neighbor2]
    }

    tp_ospf_attr_empty_def = Netomox::DSL::TermPoint.new(parent.call('nodeX'), 'tpX')
    tp_ospf_attr1_def = Netomox::DSL::TermPoint.new(parent.call('nodeX'), 'tpX') do
      attribute(tp_ospf_attr1)
    end
    tp_ospf_attr2_def = Netomox::DSL::TermPoint.new(parent.call('nodeX'), 'tpX') do
      attribute(tp_ospf_attr2)
    end
    tp_ospf_attr3_def = Netomox::DSL::TermPoint.new(parent.call('nodeX'), 'tpX') do
      attribute(tp_ospf_attr3)
    end
    tp_ospf_attr4_def = Netomox::DSL::TermPoint.new(parent.call('nodeX'), 'tpX') do
      attribute(tp_ospf_attr4)
    end
    tp_ospf_attr5_def = Netomox::DSL::TermPoint.new(parent.call('nodeX'), 'tpX') do
      attribute(tp_ospf_attr5)
    end

    @tp_ospf_attr_empty = Netomox::Topology::TermPoint.new(tp_ospf_attr_empty_def.topo_data, '')
    @tp_ospf_attr1 = Netomox::Topology::TermPoint.new(tp_ospf_attr1_def.topo_data, '')
    @tp_ospf_attr2 = Netomox::Topology::TermPoint.new(tp_ospf_attr2_def.topo_data, '')
    @tp_ospf_attr3 = Netomox::Topology::TermPoint.new(tp_ospf_attr3_def.topo_data, '')
    @tp_ospf_attr4 = Netomox::Topology::TermPoint.new(tp_ospf_attr4_def.topo_data, '')
    @tp_ospf_attr5 = Netomox::Topology::TermPoint.new(tp_ospf_attr5_def.topo_data, '')
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'kept ospf attribute' do
    d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr1.dup)
    expect(d_tp.diff_state.detect).to eq :kept
    expect(d_tp.attribute.diff_state.detect).to eq :kept
    expect(d_tp.attribute.timer.diff_state.detect).to eq :kept
    list = d_tp.attribute.neighbors.map { |d| d.diff_state.detect }
    expect(list).to eq %i[kept]
  end

  context 'diff with no-attribute term-point' do
    it 'added whole ospf attribute' do
      d_tp = @tp_ospf_attr_empty.diff(@tp_ospf_attr1)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :added
      expect(d_tp.attribute.timer.diff_state.detect).to eq :added
      list = d_tp.attribute.neighbors.map { |d| d.diff_state.detect }
      expect(list).to eq %i[added]
    end

    it 'deleted whole ospf attribute' do
      d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr_empty)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :deleted
      expect(d_tp.attribute.timer.diff_state.detect).to eq :deleted
      list = d_tp.attribute.neighbors.map { |d| d.diff_state.detect }
      expect(list).to eq %i[deleted]
    end
  end

  context 'diff with sub-attribute of term-point attribute' do
    it 'changed a literal attribute' do
      d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr2)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      expect(d_tp.attribute.timer.diff_state.detect).to eq :kept
      list = d_tp.attribute.neighbors.map { |d| d.diff_state.detect }
      expect(list).to eq %i[kept]
    end

    it 'changed a sub-module, timer' do
      d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr3)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      expect(d_tp.attribute.timer.diff_state.detect).to eq :changed
      list = d_tp.attribute.neighbors.map { |d| d.diff_state.detect }
      expect(list).to eq %i[kept]
    end

    it 'changed a sub-module, neighbors' do
      d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr4)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      expect(d_tp.attribute.timer.diff_state.detect).to eq :kept
      list = d_tp.attribute.neighbors.map { |d| d.diff_state.detect }
      # NOTICE:
      # redistribute attribute attr_neighbor1 != attr_neighbor2
      # so, it will be `added` and `deleted`, not `kept`
      expect(list).to eq %i[deleted added]
    end

    it 'added a sub-attribute, neighbors' do
      d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr5)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      expect(d_tp.attribute.timer.diff_state.detect).to eq :kept
      list = d_tp.attribute.neighbors.map { |d| d.diff_state.detect }
      expect(list).to eq %i[kept added]
    end

    it 'deleted a sub-attribute, neighbors' do
      d_tp = @tp_ospf_attr5.diff(@tp_ospf_attr1)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      expect(d_tp.attribute.timer.diff_state.detect).to eq :kept
      list = d_tp.attribute.neighbors.map { |d| d.diff_state.detect }
      expect(list).to eq %i[kept deleted]
    end

    it 'can convert to data, timer' do
      d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr3)
      data = {
        '_diff_state_' => { forward: :changed, backward: nil, pair: 'attribute' },
        'network-type' => 'BROADCAST', 'priority' => 10, 'metric' => 1, 'passive' => false,
        'timer' => {
          '_diff_state_' => { forward: :changed, backward: nil, pair: '' },
          'hello-interval' => 5, 'dead-interval' => 40, 'retransmission-interval' => 5
        },
        'neighbor' => [
          {
            '_diff_state_' => { forward: :kept, backward: nil, pair: 'attribute' },
            'router-id' => '192.168.0.1', 'ip-address' => '172.16.0.1'
          }
        ]
      }
      expect(d_tp.attribute.to_data).to eq data
    end
  end
  # rubocop:enable RSpec/MultipleExpectations
end
