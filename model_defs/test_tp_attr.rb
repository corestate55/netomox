require 'json'
require_relative '../model_dsl/dsl'

model_dir = 'model/'

# test data for termination point diff
# TODO: L2 term point attribute has Array (Array keep/add/del/change)

vlan_a = { id: 10, name: 'Seg.A' }
vlan_a_changed = { id: 11, name: 'Seg.A' }
access_vlan_a = {
  port_vlan_id: 10,
  vlan_id_names: [vlan_a]
}
access_vlan_a_change = {
  port_vlan_id: 10,
  vlan_id_names: [vlan_a_changed]
}

test_tp_attr1 = NWTopoDSL::Networks.new do
  network 'layerX' do
    type NWTopoDSL::NWTYPE_L2
    node 'nodeX' do
      term_point 'p1' do
        attribute(access_vlan_a)
      end
    end
  end
end

test_tp_attr2 = NWTopoDSL::Networks.new do
  network 'layerX' do
    type NWTopoDSL::NWTYPE_L2
    node 'nodeX' do
      term_point 'p1' do
        attribute(access_vlan_a_change)
      end
    end
  end
end

File.open("#{model_dir}/test_tp_attr1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_tp_attr1.topo_data))
end

File.open("#{model_dir}/test_tp_attr2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_tp_attr2.topo_data))
end
