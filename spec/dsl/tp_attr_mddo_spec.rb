# frozen_string_literal: true

RSpec.describe 'termination point dsl', :dsl, :tp do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'test-L1' do
        type Netomox::NWTYPE_MDDO_L1
        node 'l1node'
      end
      network 'test-L2' do
        type Netomox::NWTYPE_MDDO_L2
        node 'l2node'
      end
      network 'test-L3' do
        type Netomox::NWTYPE_MDDO_L3
        node 'l3node'
      end
    end
    @l1node = nws.network('test-L1').node('l1node')
    @l2node = nws.network('test-L2').node('l2node')
    @l3node = nws.network('test-L3').node('l3node')

    @l1attr_key = "#{Netomox::NS_MDDO}:l1-termination-point-attributes"
    @l2attr_key = "#{Netomox::NS_MDDO}:l2-termination-point-attributes"
    @l3attr_key = "#{Netomox::NS_MDDO}:l3-termination-point-attributes"
  end

  it 'generate term point that has L1 attribute', :attr, :l1attr do
    tp_attr = { description: 'tp descr', flags: %w[foo bar] }
    tp = Netomox::DSL::TermPoint.new(@l1node, 'tpX') do
      attribute(tp_attr)
    end
    tp_data = {
      'tp-id' => 'tpX',
      @l1attr_key => {
        'description' => 'tp descr',
        'flag' => %w[foo bar]
      }
    }
    expect(tp.topo_data).to eq tp_data
  end

  it 'generate term point that has L2 attribute', :attr, :l2attr do
    tp_attr = { description: 'tp descr', encapsulation: 'dot1q', switchport_mode: 'trunk', flags: %w[foo bar] }
    tp = Netomox::DSL::TermPoint.new(@l2node, 'tpX') do
      attribute(tp_attr)
    end
    tp_data = {
      'tp-id' => 'tpX',
      @l2attr_key => {
        'description' => 'tp descr',
        'encapsulation' => 'dot1q',
        'switchport-mode' => 'trunk',
        'flag' => %w[foo bar]
      }
    }
    expect(tp.topo_data).to eq tp_data
  end

  it 'generate term point that has L3 attribute', :attr, :l3attr do
    tp_attr = { description: 'tp descr', ip_addrs: %w[192.168.3.2/24 192.168.3.1/24], flags: %w[foo bar] }
    tp = Netomox::DSL::TermPoint.new(@l3node, 'tpX') do
      attribute(tp_attr)
    end
    tp_data = {
      'tp-id' => 'tpX',
      @l3attr_key => {
        'description' => 'tp descr',
        'ip-address' => %w[192.168.3.2/24 192.168.3.1/24],
        'flag' => %w[foo bar]
      }
    }
    expect(tp.topo_data).to eq tp_data
  end
end
