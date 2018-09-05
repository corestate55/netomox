require 'json'
require 'netomox'

model_dir = 'model/'

# test data for network diff
# TODO: network type check

test_network1 = Netomox::DSL::Networks.new do
  network 'nw_kept'
  network 'nw_deleted'

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

test_network2 = Netomox::DSL::Networks.new do
  network 'nw_kept'
  network 'nw_added'

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

File.open("#{model_dir}/test_network1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_network1.topo_data))
end

File.open("#{model_dir}/test_network2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_network2.topo_data))
end
