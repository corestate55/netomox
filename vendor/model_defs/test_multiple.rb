require 'json'
require 'netomox'

model_dir = 'model/'

test_nws1 = Netomox::DSL::Networks.new do
  network 'layer1' do
    sw1 = node 'sw1'
    sv1 = node 'sv1'
    sv2 = node 'sv2'
    sw1.tp_prefix = 'gi'
    sv1.tp_prefix = 'eth'
    sv2.tp_prefix = 'eth'
    sw1.bdlink_to(sv1)
    sw1.bdlink_to(sv2)
  end

  network 'layer3' do
    seg_a_prefix = { prefix: '192.168,10.0/24', metric: 100 }
    seg_b_prefix = { prefix: '192.168.20.0/24', metric: 100 }
    seg_c_prefix = { prefix: '192.168.30.0/24', metric: 100 }
    pref_a = { prefixes: [seg_a_prefix] }
    pref_b = { prefixes: [seg_b_prefix] }
    pref_c = { prefixes: [seg_c_prefix] }
    pref_ab = { prefixes: [seg_a_prefix, seg_b_prefix] }
    pref_bc = { prefixes: [seg_b_prefix, seg_c_prefix] }

    type Netomox::NWTYPE_L3
    support 'layer1'

    seg_a = node 'seg_a' do
      attribute(pref_a)
      support %w[layer1 sw1]
      support %w[layer1 sv1]
      support %w[layer1 sv2]
    end
    seg_b = node 'seg_b' do
      support %w[layer1 sw1]
      support %w[layer1 sv1]
      support %w[layer1 sv2]
      attribute(pref_b)
    end
    seg_c = node 'seg_c' do
      support %w[layer1 sv2]
      attribute(pref_c)
    end
    vm1 = node 'vm1' do
      attribute(pref_a)
      support %w[layer1 sv1]
    end
    vm2 = node 'vm2' do
      attribute(pref_ab)
      support %w[layer1 sv1]
    end
    vm3 = node 'vm3' do
      attribute(pref_bc)
      support %w[layer1 sv2]
    end
    [vm1, vm2, vm3].each { |vm| vm.tp_prefix = 'eth' }

    seg_a.bdlink_to(vm1)
    seg_a.bdlink_to(vm2)
    seg_b.bdlink_to(vm2)
    seg_b.bdlink_to(vm3)
    seg_c.bdlink_to(vm3)
  end
end

test_nws2 = Netomox::DSL::Networks.new do
  network 'layer1' do
    sw1 = node 'sw1'
    sv1 = node 'sv1'
    sv2 = node 'sv2'
    sw1.tp_prefix = 'gi'
    sv1.tp_prefix = 'eth'
    sv2.tp_prefix = 'eth'
    sw1.bdlink_to(sv1)
    sw1.bdlink_to(sv2)
  end

  network 'layer3' do
    seg_a_prefix = { prefix: '192.168,10.0/24', metric: 100 }
    seg_b_prefix = { prefix: '192.168.20.0/24', metric: 100 }
    seg_c_prefix = { prefix: '192.168.30.0/24', metric: 100 }
    pref_a = { prefixes: [seg_a_prefix] }
    pref_b = { prefixes: [seg_b_prefix] }
    pref_c = { prefixes: [seg_c_prefix] }
    pref_ab = { prefixes: [seg_a_prefix, seg_b_prefix] }
    pref_bc = { prefixes: [seg_b_prefix, seg_c_prefix] }

    type Netomox::NWTYPE_L3
    support 'layer1'

    seg_a = node 'seg_a' do
      attribute(pref_a)
      support %w[layer1 sw1]
      support %w[layer1 sv1]
      support %w[layer1 sv2]
    end
    seg_b = node 'seg_b' do
      support %w[layer1 sw1]
      support %w[layer1 sv1]
      support %w[layer1 sv2]
      attribute(pref_b)
    end
    seg_c = node 'seg_c' do
      support %w[layer1 sv2]
      attribute(pref_c)
    end
    vm1 = node 'vm1' do
      attribute(pref_ab)
      support %w[layer1 sv1]
    end
    vm3 = node 'vm3' do
      attribute(pref_bc)
      support %w[layer1 sv1]
    end
    vm4 = node 'vm4' do
      attribute(pref_c)
      support %w[layer1 sv2]
    end
    [vm1, vm3, vm4].each { |vm| vm.tp_prefix = 'eth' }

    seg_a.bdlink_to(vm1)
    seg_b.bdlink_to(vm1)
    seg_b.bdlink_to(vm3)
    seg_c.bdlink_to(vm3)
    seg_c.bdlink_to(vm4)
  end
end

File.open("#{model_dir}/test_multiple1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_nws1.topo_data))
end

File.open("#{model_dir}/test_multiple2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_nws2.topo_data))
end
