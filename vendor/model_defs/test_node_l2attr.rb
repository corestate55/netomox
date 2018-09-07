require 'json'
require 'netomox'

model_dir = 'model/'

addrs = %w[192.168.0.1 192.168.1.1]
addrs_added = %w[192.168.0.1 192.168.1.1 192.168.2.1]
addrs_deleted = %w[192.168.0.1]

node_attr = { name: 'tpX', mgmt_vid: 10, mgmt_addrs: addrs }
node_attr_added = { name: 'tpX', mgmt_vid: 10, mgmt_addrs: addrs_added }
node_attr_deleted = { name: 'tpX', mgmt_vid: 10, mgmt_addrs: addrs_deleted }
node_attr_changed = { name: 'tpX', mgmt_vid: 11, mgmt_addrs: addrs }

test_node_attr1 = Netomox::DSL::Networks.new do
  network 'layerX' do
    type Netomox::NWTYPE_L2
    node 'attr_kept' do
      attribute(node_attr)
    end
    node 'attr_added' do
      attribute(node_attr)
    end
    node 'attr_added2_empty_attr'
    node 'attr_deleted' do
      attribute(node_attr)
    end
    node 'attr_deleted2_empty_attr' do
      attribute(node_attr)
    end
    node 'attr_changed' do
      attribute(node_attr)
    end
  end
end

test_node_attr2 = Netomox::DSL::Networks.new do
  network 'layerX' do
    type Netomox::NWTYPE_L2
    node 'attr_kept' do
      attribute(node_attr)
    end
    node 'attr_added' do
      attribute(node_attr_added)
    end
    node 'attr_added2_empty_attr' do
      attribute(node_attr)
    end
    node 'attr_deleted' do
      attribute(node_attr_deleted)
    end
    node 'attr_deleted2_empty_attr'
    node 'attr_changed' do
      attribute(node_attr_changed)
    end
  end
end

File.open("#{model_dir}/test_node_l2attr1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_node_attr1.topo_data))
end

File.open("#{model_dir}/test_node_l2attr2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_node_attr2.topo_data))
end
