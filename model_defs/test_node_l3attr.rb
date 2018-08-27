require 'json'
require_relative '../model_dsl/dsl'

model_dir = 'model/'

seg_a_prefix = { prefix: '192.168,10.0/24', metric: 100 }
seg_a2_prefix = { prefix: '192.168,10.0/24', metric: 50 }
seg_b_prefix = { prefix: '192.168.20.0/24', metric: 100 }
seg_c_prefix = { prefix: '192.168.30.0/24', metric: 100 }

pref = { prefixes: [seg_a_prefix, seg_b_prefix] }
pref_added = { prefixes: [seg_a_prefix, seg_b_prefix, seg_c_prefix] }
pref_deleted = { prefixes: [seg_b_prefix] }
pref_changed = { prefixes: [seg_a2_prefix, seg_b_prefix] }

test_node_attr1 = NWTopoDSL::Networks.new do
  network 'layerX' do
    type NWTopoDSL::NWTYPE_L3
    node 'attr_kept' do
      attribute(pref)
    end
    node 'attr_added' do
      attribute(pref)
    end
    node 'attr_added2_empty_attr'
    node 'attr_deleted' do
      attribute(pref)
    end
    node 'attr_deleted2_empty_attr' do
      attribute(pref)
    end
    node 'attr_changed' do
      attribute(pref)
    end
  end
end

test_node_attr2 = NWTopoDSL::Networks.new do
  network 'layerX' do
    type NWTopoDSL::NWTYPE_L3
    node 'attr_kept' do
      attribute(pref)
    end
    node 'attr_added' do
      attribute(pref_added)
    end
    node 'attr_added2_empty_attr' do
      attribute(pref)
    end
    node 'attr_deleted' do
      attribute(pref_deleted)
    end
    node 'attr_deleted2_empty_attr'
    node 'attr_changed' do
      attribute(pref_changed)
    end
  end
end

File.open("#{model_dir}/test_node_l3attr1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_node_attr1.topo_data))
end

File.open("#{model_dir}/test_node_l3attr2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_node_attr2.topo_data))
end
