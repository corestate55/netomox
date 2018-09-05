require 'json'
require 'netomox'

model_dir = 'model/'

test_network_attr1 = Netomox::DSL::Networks.new do
  network 'nw_attr_kept' do
    type Netomox::DSL::NWTYPE_L3
    attribute(name: 'layerZ', flags: %w[foo bar])
  end
  network 'nw_attr_changed' do
    type Netomox::DSL::NWTYPE_L3
    attribute(name: 'layerZ', flags: %w[foo bar])
  end
end

test_network2_attr = Netomox::DSL::Networks.new do
  network 'nw_attr_kept' do
    type Netomox::DSL::NWTYPE_L3
    attribute(name: 'layerZ', flags: %w[foo bar])
  end
  network 'nw_attr_changed' do
    type Netomox::DSL::NWTYPE_L3
    attribute(name: 'layerZ', flags: %w[hoge bar])
  end
end

File.open("#{model_dir}/test_network_attr1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_network_attr1.topo_data))
end

File.open("#{model_dir}/test_network_attr2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_network2_attr.topo_data))
end
