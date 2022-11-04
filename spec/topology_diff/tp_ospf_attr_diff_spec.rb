# frozen_string_literal: true

RSpec.describe 'termination point diff with ospf attribute', :attr, :diff, :ospf_attr, :tp do
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

  it 'kept ospf attribute' do
    d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr1.dup)
    expect(d_tp.diff_state.detect).to eq :kept
    expect(d_tp.attribute.diff_state.detect).to eq :kept
    dd_expected = []
    expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
  end

  context 'diff with no-attribute term-point' do
    it 'added whole ospf attribute' do
      d_tp = @tp_ospf_attr_empty.diff(@tp_ospf_attr1)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :added
      dd_expected = [
        ['+', '_diff_state_', { forward: :kept, backward: nil, pair: '' }],
        ['+', 'metric', 1],
        ['+', 'neighbor', [{ 'router-id' => '192.168.0.1', 'ip-address' => '172.16.0.1' }]],
        ['+', 'network-type', 'BROADCAST'],
        ['+', 'passive', false],
        ['+', 'priority', 10],
        ['+', 'timer', { 'hello-interval' => 10, 'dead-interval' => 40, 'retransmission-interval' => 5 }]
      ]
      expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted whole ospf attribute' do
      d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr_empty)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :deleted
      dd_expected = [
        ['-', '_diff_state_', { forward: :kept, backward: nil, pair: '' }],
        ['-', 'metric', 1],
        ['-', 'neighbor', [{ 'router-id' => '192.168.0.1', 'ip-address' => '172.16.0.1' }]],
        ['-', 'network-type', 'BROADCAST'],
        ['-', 'passive', false],
        ['-', 'priority', 10],
        ['-', 'timer', { 'hello-interval' => 10, 'dead-interval' => 40, 'retransmission-interval' => 5 }]
      ]
      expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
    end
  end

  context 'diff with sub-attribute of term-point attribute' do
    it 'changed a literal attribute' do
      d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr2)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      dd_expected = [%w[~ network-type BROADCAST P2P]]
      expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'changed a sub-module, timer' do
      d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr3)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      dd_expected = [['~', 'timer.hello-interval', 10, 5]]
      expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'changed a sub-module, neighbors' do
      d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr4)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'neighbor[0]', { 'router-id' => '192.168.0.1', 'ip-address' => '172.16.0.1' }],
        ['+', 'neighbor[0]', { 'router-id' => '192.168.0.2', 'ip-address' => '172.16.0.1' }]
      ]
      expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'added a sub-attribute, neighbors' do
      d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr5)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      dd_expected = [['+', 'neighbor[1]', { 'router-id' => '192.168.0.2', 'ip-address' => '172.16.0.1' }]]
      expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted a sub-attribute, neighbors' do
      d_tp = @tp_ospf_attr5.diff(@tp_ospf_attr1)
      expect(d_tp.diff_state.detect).to eq :changed
      expect(d_tp.attribute.diff_state.detect).to eq :changed
      dd_expected = [['-', 'neighbor[1]', { 'router-id' => '192.168.0.2', 'ip-address' => '172.16.0.1' }]]
      expect(d_tp.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'can convert to data, timer' do
      d_tp = @tp_ospf_attr1.diff(@tp_ospf_attr3)
      data = {
        '_diff_state_' => {
          forward: :changed, backward: nil, pair: 'attribute', diff_data: [['~', 'timer.hello-interval', 10, 5]]
        },
        'network-type' => 'BROADCAST', 'priority' => 10, 'metric' => 1, 'passive' => false,
        'timer' => { 'hello-interval' => 5, 'dead-interval' => 40, 'retransmission-interval' => 5 },
        'neighbor' => [{ 'router-id' => '192.168.0.1', 'ip-address' => '172.16.0.1' }]
      }
      expect(d_tp.attribute.to_data).to eq data
    end
  end
end
