require 'json'
require_relative 'model_dsl/dsl'

nws = ModelDSL::Networks.new do
  network 'target-L1'
  network 'target-L1.5' do
    support 'target-L1'
  end
  network 'target-L2' do
    type ModelDSL::NWTYPE_L2
    support 'target-L1'
    support 'target-L1.5'
  end
  network 'target-L3' do
    type ModelDSL::NWTYPE_L3
    support 'target-L1'
    support 'target-L1.5'
    support 'target-L2'
    node 'GRT-vRT' do
      term_point 'p1' do
        support 'target-L3', 'R1-GRT', 'p1'
        support 'target-L3', 'R2-GRT', 'p1'
      end
      term_point 'p2' do
        support 'target-L3', 'R1-GRT', 'p2'
        support 'target-L3', 'R2-GRT', 'p2'
      end
      support 'target-L3', 'R1'
      support 'target-L3', 'R2'
    end
    bdlink 'GRT-vRT', 'p1', 'Seg.A', 'p0'
  end
end

puts JSON.pretty_generate(nws.topo_data)
