require 'json'
require_relative '../model_dsl/dsl'

link_attr_a = { name: 'linkX', flags: [], metric1: 100, metric2: 100 }
link_attr_b = { name: 'linkX', flags: [], metric1: 200, metric2: 200 }

model_dir = 'model/'
test_link_attr1 = NWTopoDSL::Networks.new do
  network 'layerX' do
    type NWTopoDSL::NWTYPE_L3
    bdlink %w[attr_kept1 p1 attr_kept2 p1] do
      attribute(link_attr_a)
    end
    bdlink %w[attr_added_empty_attr1 p1 attr_added_empty_attr2 p1]
    bdlink %w[attr_deleted_empty_attr1 p1 attr_deleted_empty_attr2 p1] do
      attribute(link_attr_a)
    end
    bdlink %w[attr_changed1 p1 attr_changed2 p1] do
      attribute(link_attr_a)
    end
  end
end

test_link_attr2 = NWTopoDSL::Networks.new do
  network 'layerX' do
    type NWTopoDSL::NWTYPE_L3
    bdlink %w[attr_kept1 p1 attr_kept2 p1] do
      attribute(link_attr_a)
    end
    bdlink %w[attr_added_empty_attr1 p1 attr_added_empty_attr2 p1] do
      attribute(link_attr_a)
    end
    bdlink %w[attr_deleted_empty_attr1 p1 attr_deleted_empty_attr2 p1]
    bdlink %w[attr_changed1 p1 attr_changed2 p1] do
      attribute(link_attr_b)
    end
  end
end

File.open("#{model_dir}/test_link_attr1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_link_attr1.topo_data))
end

File.open("#{model_dir}/test_link_attr2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_link_attr2.topo_data))
end
