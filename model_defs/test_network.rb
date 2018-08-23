require 'json'
require_relative '../model_dsl/dsl'

model_dir = 'model/'

# test data for network diff
# TODO: network type check

test_nw1 = NWTopoDSL::Networks.new do
  network 'nw_kept'
  network 'nw_deleted'

  network 'nw_attr_kept' do
    attribute(name: 'layerZ', flags: %w[foo bar])
  end
  network 'nw_attr_changed' do
    attribute(name: 'layerZ', flags: %w[foo bar])
  end

  network 'nw_support_kept' do
    support 'layerX'
    support 'layerZ'
  end
  network 'nw_support_added' do
    support 'layerZ'
  end
  network 'nw_support_deleted' do
    support 'layerZ'
    support 'layerX'
  end
  network 'nw_support_changed' do
    support 'layerX'
    support 'layerZ'
  end
end

test_nw2 = NWTopoDSL::Networks.new do
  network 'nw_kept'
  network 'nw_added'

  network 'nw_attr_kept' do
    attribute(name: 'layerZ', flags: %w[foo bar])
  end
  network 'nw_attr_changed' do
    attribute(name: 'layerZ', flags: %w[hoge bar])
  end

  network 'nw_support_kept' do
    support 'layerX'
    support 'layerZ'
  end
  network 'nw_support_added' do
    support 'layerZ'
    support 'layerX'
  end
  network 'nw_support_deleted' do
    support 'layerZ'
  end
  network 'nw_support_changed' do
    support 'layerXXX'
    support 'layerZ'
  end
end

File.open("#{model_dir}/test_nw1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_nw1.topo_data))
end

File.open("#{model_dir}/test_nw2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_nw2.topo_data))
end
