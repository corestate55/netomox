require 'json'
require_relative '../model_dsl/dsl'

model_dir = 'model/'

# test data for termination point diff
# TODO: L2 term point attribute has Array (Array keep/add/del/change)

vlan_a = { id: 10, name: 'Seg.A' }
vlan_b = { id: 20, name: 'Seg.B' }
vlan_a_changed = { id: 11, name: 'Seg.A' }
access_vlan_a = {
  port_vlan_id: 10,
  vlan_id_names: [vlan_a, vlan_b]
}
access_vlan_a_added = {
  port_vlan_id: 10,
  vlan_id_names: [vlan_a, vlan_a_changed, vlan_b]
}
access_vlan_a_deleted = {
  port_vlan_id: 10,
  vlan_id_names: [vlan_a]
}
access_vlan_a_changed = {
  port_vlan_id: 10,
  vlan_id_names: [vlan_a_changed, vlan_b]
}

test_tp_attr1 = NWTopoDSL::Networks.new do
  network 'layerX' do
    type NWTopoDSL::NWTYPE_L2
    node 'nodeX' do
      term_point 'attr_kept' do
        attribute(access_vlan_a)
      end
      term_point 'attr_added' do
        attribute(access_vlan_a)
      end
      term_point 'attr_added2_empty_attr'
      term_point 'attr_deleted' do
        attribute(access_vlan_a)
      end
      term_point 'attr_deleted2_empty_attr' do
        attribute(access_vlan_a)
      end
      term_point 'attr_changed' do
        attribute(access_vlan_a)
      end
    end
  end
end

test_tp_attr2 = NWTopoDSL::Networks.new do
  network 'layerX' do
    type NWTopoDSL::NWTYPE_L2
    node 'nodeX' do
      term_point 'attr_kept' do
        attribute(access_vlan_a)
      end
      term_point 'attr_added' do
        attribute(access_vlan_a_added)
      end
      term_point 'attr_added2_empty_attr' do
        attribute(access_vlan_a)
      end
      term_point 'attr_deleted' do
        attribute(access_vlan_a_deleted)
      end
      term_point 'attr_deleted2_empty_attr'
      term_point 'attr_changed' do
        attribute(access_vlan_a_changed)
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
