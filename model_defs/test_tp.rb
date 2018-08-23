require 'json'
require_relative '../model_dsl/dsl'

model_dir = 'model/'

# test data for termination point diff
# TODO: L2 term point attribute has Array (Array keep/add/del/change)

vlan_a = { id: 10, name: 'Seg.A' }
access_vlan_a = {
  port_vlan_id: 10,
  vlan_id_names: [vlan_a]
}
access_vlan_a_change = {
  port_vlan_id: 11,
  vlan_id_names: [vlan_a]
}

test_tp1 = NWTopoDSL::Networks.new do
  network 'layerX' do
    type NWTopoDSL::NWTYPE_L2
    node 'nodeX' do
      term_point 'tp_kept'
      term_point 'tp_deleted'

      term_point 'tp_attr_kept' do
        attribute(access_vlan_a)
      end
      term_point 'tp_attr_changed' do
        attribute(access_vlan_a)
      end

      term_point 'tp_support_kept' do
        support %w[foo bar baz]
        support %w[foo bar hoge]
      end
      term_point 'tp_support_added' do
        support %w[foo bar hoge]
      end
      term_point 'tp_support_deleted' do
        support %w[foo bar baz]
        support %w[foo bar hoge]
      end
      term_point 'tp_support_changed' do
        support %w[foo bar baz]
        support %w[foo bar hoge]
      end
    end
  end
end

test_tp2 = NWTopoDSL::Networks.new do
  network 'layerX' do
    type NWTopoDSL::NWTYPE_L2
    node 'nodeX' do
      term_point 'tp_kept'
      term_point 'tp_added'

      term_point 'tp_attr_kept' do
        attribute(access_vlan_a)
      end
      term_point 'tp_attr_changed' do
        attribute(access_vlan_a_change)
      end

      term_point 'tp_support_kept' do
        support %w[foo bar baz]
        support %w[foo bar hoge]
      end
      term_point 'tp_support_added' do
        support %w[foo bar baz]
        support %w[foo bar hoge]
      end
      term_point 'tp_support_deleted' do
        support %w[foo bar baz]
      end
      term_point 'tp_support_changed' do
        support %w[foo bar baz]
        support %w[foo bar hoge_hoge]
      end
    end
  end
end

File.open("#{model_dir}/test_tp1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_tp1.topo_data))
end

File.open("#{model_dir}/test_tp2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_tp2.topo_data))
end
