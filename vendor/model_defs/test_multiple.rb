require 'json'
require 'netomox'

model_dir = 'model/'

test_nws1 = Netomox::DSL::Networks.new do
  network 'layer1' do
    node 'sw1' do
      term_point 'gi0'
      term_point 'gi1'
    end
    node 'sv1' do
      term_point 'eth0'
    end
    node 'sv2' do
      term_point 'eth0'
    end

    bdlink %w[sw1 gi0 sv1 eth0]
    bdlink %w[sw1 gi1 sv2 eth0]
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

    node 'seg_a' do
      attribute(pref_a)
      support %w[layer1 sw1]
      support %w[layer1 sv1]
      support %w[layer1 sv2]
      term_point 'p1'
      term_point 'p2'
    end
    node 'seg_b' do
      support %w[layer1 sw1]
      support %w[layer1 sv1]
      support %w[layer1 sv2]
      attribute(pref_b)
      term_point 'p1'
      term_point 'p2'
    end
    node 'seg_c' do
      support %w[layer1 sv2]
      attribute(pref_c)
      term_point 'p1'
    end
    node 'vm1' do
      attribute(pref_a)
      support %w[layer1 sv1]
      term_point 'eth0'
    end
    node 'vm2' do
      attribute(pref_ab)
      support %w[layer1 sv2]
      term_point 'eth0'
      term_point 'eth1'
    end
    node 'vm3' do
      attribute(pref_bc)
      support %w[layer1 sv2]
      term_point 'eth0'
      term_point 'eth1'
    end

    bdlink %w[seg_a p1 vm1 eth0]
    bdlink %w[seg_a p2 vm2 eth0]
    bdlink %w[seg_b p1 vm2 eth1]
    bdlink %w[seg_b p2 vm3 eth0]
    bdlink %w[seg_c p1 vm3 eth1]
  end
end

test_nws2 = Netomox::DSL::Networks.new do
  network 'layer1' do
    node 'sw1' do
      term_point 'gi0'
      term_point 'gi1'
    end
    node 'sv1' do
      term_point 'eth0'
    end
    node 'sv2' do
      term_point 'eth0'
    end

    bdlink %w[sw1 gi0 sv1 eth0]
    bdlink %w[sw1 gi1 sv2 eth0]
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

    node 'seg_a' do
      attribute(pref_a)
      support %w[layer1 sw1]
      support %w[layer1 sv1]
      support %w[layer1 sv2]
      term_point 'p1'
    end
    node 'seg_b' do
      support %w[layer1 sw1]
      support %w[layer1 sv1]
      support %w[layer1 sv2]
      attribute(pref_b)
      term_point 'p1'
      term_point 'p2'
    end
    node 'seg_c' do
      support %w[layer1 sv2]
      attribute(pref_c)
      term_point 'p1'
      term_point 'p2'
    end
    node 'vm1' do
      attribute(pref_ab)
      support %w[layer1 sv1]
      term_point 'eth0'
      term_point 'eth1'
    end
    node 'vm3' do
      attribute(pref_bc)
      support %w[layer1 sv2]
      term_point 'eth0'
      term_point 'eth1'
    end
    node 'vm4' do
      attribute(pref_c)
      support %w[layer1 sv2]
      term_point 'eth0'
    end

    bdlink %w[seg_a p1 vm1 eth0]
    bdlink %w[seg_b p1 vm1 eth1]
    bdlink %w[seg_b p2 vm3 eth0]
    bdlink %w[seg_c p1 vm3 eth1]
    bdlink %w[seg_c p2 vm4 eth0]
  end
end

File.open("#{model_dir}/test_multiple1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_nws1.topo_data))
end

File.open("#{model_dir}/test_multiple2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_nws2.topo_data))
end
