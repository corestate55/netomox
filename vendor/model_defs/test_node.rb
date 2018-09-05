require 'json'
require 'netomox'

model_dir = 'model/'

# test data for node diff

test_node1 = Netomox::DSL::Networks.new do
  network 'layerX' do
    type Netomox::DSL::NWTYPE_L2
    node 'node_kept'
    node 'node_deleted'

    node 'node_support_kept' do
      support %w[hoge foo]
      support %w[hoge bar]
    end
    node 'node_support_added' do
      support %w[hoge bar]
    end
    node 'node_support_deleted' do
      support %w[hoge foo]
      support %w[hoge bar]
    end
    node 'node_support_changed' do
      support %w[hoge foo]
      support %w[hoge bar]
    end
  end
end

test_node2 = Netomox::DSL::Networks.new do
  network 'layerX' do
    type Netomox::DSL::NWTYPE_L2
    node 'node_kept'
    node 'node_added'

    node 'node_support_kept' do
      support %w[hoge foo]
      support %w[hoge bar]
    end
    node 'node_support_added' do
      support %w[hoge foo]
      support %w[hoge bar]
    end
    node 'node_support_deleted' do
      support %w[hoge bar]
    end
    node 'node_support_changed' do
      support %w[hoge fooooo]
      support %w[hoge bar]
    end
  end
end

File.open("#{model_dir}/test_node1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_node1.topo_data))
end

File.open("#{model_dir}/test_node2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_node2.topo_data))
end
