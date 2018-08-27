require 'json'
require_relative '../model_dsl/dsl'

model_dir = 'model/'

# test data for termination point diff

tp_attr = { ip_addrs: %w[192.168.0.1 192.168.1.1] }
tp_attr_added = { ip_addrs: %w[192.168.0.1 192.168.1.1 192.168.2.1] }
tp_attr_deleted = { ip_addrs: %w[192.168.0.1] }
tp_attr_changed = { ip_addrs: %w[192.168.0.1 192.168.1.2] }

test_tp_attr1 = NWTopoDSL::Networks.new do
  network 'layerX' do
    type NWTopoDSL::NWTYPE_L3
    node 'nodeX' do
      term_point 'attr_kept' do
        attribute(tp_attr)
      end
      term_point 'attr_added' do
        attribute(tp_attr)
      end
      term_point 'attr_added2_empty_attr'
      term_point 'attr_deleted' do
        attribute(tp_attr)
      end
      term_point 'attr_deleted2_empty_attr' do
        attribute(tp_attr)
      end
      term_point 'attr_changed' do
        attribute(tp_attr)
      end
    end
  end
end

test_tp_attr2 = NWTopoDSL::Networks.new do
  network 'layerX' do
    type NWTopoDSL::NWTYPE_L3
    node 'nodeX' do
      term_point 'attr_kept' do
        attribute(tp_attr)
      end
      term_point 'attr_added' do
        attribute(tp_attr_added)
      end
      term_point 'attr_added2_empty_attr' do
        attribute(tp_attr)
      end
      term_point 'attr_deleted' do
        attribute(tp_attr_deleted)
      end
      term_point 'attr_deleted2_empty_attr'
      term_point 'attr_changed' do
        attribute(tp_attr_changed)
      end
    end
  end
end

File.open("#{model_dir}/test_tp_l3attr1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_tp_attr1.topo_data))
end

File.open("#{model_dir}/test_tp_l3attr2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_tp_attr2.topo_data))
end
