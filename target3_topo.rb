require 'json'
require_relative 'model_dsl/dsl'

nws = ModelDSL::Networks.new do
  network 'target-L1' do
    node 'R1' do
      term_point 'Fa0'
      term_point 'Fa1'
      term_point 'Fa2'
      term_point 'Po1' do
        support 'target-L1', 'R1', 'Fa0'
        support 'target-L1', 'R1', 'Fa1'
      end
    end
    node 'R2' do
      term_point 'Fa0'
      term_point 'Fa1'
      term_point 'Fa2'
      term_point 'Po1' do
        support 'target-L1', 'R2', 'Fa0'
        support 'target-L1', 'R2', 'Fa1'
      end
    end
    node 'SW1' do
      (0..2).each{|n| term_point "Fa#{n}"}
    end
    node 'SW2' do
      (0..4).each{|n| term_point "Fa#{n}"}
    end
    node 'HYP1' do
      (0..1).each{|n| term_point "eth#{n}"}
    end
    node 'SV1' do
      term_point 'eth0'
    end
    node 'SV2' do
      term_point 'eth0'
    end
    bdlink 'R1', 'Fa0', 'R2', 'Fa0'
    bdlink 'R1', 'Fa1', 'R2', 'Fa1'
    bdlink 'R1', 'Po1', 'R2', 'Po1'
    bdlink 'R1', 'Fa2', 'SW1', 'Fa1'
    bdlink 'R2', 'Fa2', 'SW2', 'Fa1'
    bdlink 'SW1', 'Fa0', 'SW2', 'Fa0'
    bdlink 'SW1', 'Fa2', 'HYP1', 'eth0'
    bdlink 'SW2', 'Fa2', 'HYP1', 'eth1'
    bdlink 'SW2', 'Fa3', 'SV1', 'eth0'
    bdlink 'SW2', 'Fa4', 'SV2', 'eth0'
  end

  network 'target-L1.5' do
    support 'target-L1'
    node 'HYP1-vSW1' do
      term_point 'eth0' do
        support 'target-L1', 'HYP1', 'eth0'
      end
      term_point 'eth1' do
        support 'target-L1', 'HYP1', 'eth1'
      end
      (1..2).each{|n| term_point "p#{n}"}
      support 'target-L1', 'HYP1'
    end
    node 'VM1' do
      term_point 'eth0'
      support 'target-L1', 'HYP1'
    end
    node 'VM2' do
      term_point 'eth0'
      support 'target-L1', 'HYP1'
    end
    bdlink 'HYP1-vSW1', 'p1', 'VM1', 'eth0'
    bdlink 'HYP1-vSW1', 'p2', 'VM2', 'eth0'
  end

  network 'target-L2' do
    type ModelDSL::NWTYPE_L2
    support 'target-L1'
    support 'target-L1.5'
    node 'R1-GRT' do
      term_point 'p1'
      support 'target-L1', 'R1'
    end
    node 'R1-BR' do
      term_point 'p1'
      term_point 'p2' do
        support 'target-L1', 'R1', 'Po1'
      end
      term_point 'p3' do
        support 'target-L1', 'R1', 'Fa2'
      end
      support 'target-L1', 'R1'
    end
    node 'R2-GRT' do
      term_point 'p1'
      support 'target-L1', 'R2'
    end
    node 'R2-BR' do
      term_point 'p1'
      term_point 'p2' do
        support 'target-L1', 'R2', 'Po1'
      end
      term_point 'p3' do
        support 'target-L1', 'R2', 'Fa2'
      end
      support 'target-L1', 'R2'
    end
    node 'SW1-BR' do
      term_point 'p1' do
        support 'target-L1', 'SW1', 'Fa1'
      end
      term_point 'p2' do
        support 'target-L1', 'SW1', 'Fa0'
      end
      term_point 'p3' do
        support 'target-L1', 'SW1', 'Fa2'
      end
      support 'target-L1', 'SW1'
    end
    node 'SW2-BR' do
      term_point 'p1' do
        support 'target-L1', 'SW2', 'Fa1'
      end
      term_point 'p2' do
        support 'target-L1', 'SW2', 'Fa0'
      end
      term_point 'p3' do
        support 'target-L1', 'SW2', 'Fa2'
      end
      term_point 'p4' do
        support 'target-L1', 'SW2', 'Fa3'
      end
      term_point 'p5' do
        support 'target-L1', 'SW2', 'Fa4'
      end
      term_point 'p6' do
        support 'target-L1', 'SW2', 'Fa4'
      end
      support 'target-L1', 'SW2'
    end
    node 'HYP1-vSW1-BR' do
      term_point 'p1' do
        support 'target-L1.5', 'HYP1-vSW1', 'eth0'
      end
      term_point 'p2' do
        support 'target-L1.5', 'HYP1-vSW1', 'eth1'
      end
      term_point 'p3' do
        support 'target-L1.5', 'HYP1-vSW1', 'p1'
      end
      term_point 'p4' do
        support 'target-L1.5', 'HYP1-vSW1', 'p2'
      end
      term_point 'p5' do
        support 'target-L1.5', 'HYP1-vSW1', 'p2'
      end
      support 'target-L1.5', 'HYP1-vSW1'
    end
    node 'VM1' do
      term_point 'eth0' do
        support 'target-L1.5', 'VM1', 'eth0'
      end
      support 'target-L1.5', 'VM1'
    end
    node 'VM2' do
      term_point 'eth0.20' do
        support 'target-L1.5', 'VM2', 'eth0'
      end
      term_point 'eth0.30' do
        support 'target-L1.5', 'VM2', 'eth0'
      end
      support 'target-L1.5', 'VM2'
    end
    node 'SV1' do
      term_point 'eth0' do
        support 'target-L1', 'SV1', 'eth0'
      end
      support 'target-L1', 'SV1'
    end
    node 'SV2' do
      term_point 'eth0.20' do
        support 'target-L1', 'SV2', 'eth0'
      end
      term_point 'eth0.30' do
        support 'target-L1', 'SV2', 'eth0'
      end
      support 'target-L1', 'SV2'
    end
    bdlink 'R1-GRT', 'p1', 'R1-BR', 'p1'
    bdlink 'R2-GRT', 'p1', 'R2-BR', 'p1'
    bdlink 'R1-BR', 'p2', 'R2-BR', 'p2'
    bdlink 'R1-BR', 'p3', 'SW1-BR', 'p1'
    bdlink 'R2-BR', 'p3', 'SW2-BR', 'p1'
    bdlink 'SW1-BR', 'p2', 'SW2-BR', 'p2'
    bdlink 'SW1-BR', 'p3', 'HYP1-vSW1-BR', 'p1'
    bdlink 'SW2-BR', 'p3', 'HYP1-vSW1-BR', 'p2'
    bdlink 'SW2-BR', 'p4', 'SV1', 'eth0'
    bdlink 'HYP1-vSW1-BR', 'p3', 'VM1', 'eth0'
    bdlink 'HYP1-vSW1-BR', 'p4', 'VM2', 'eth0.20'
    bdlink 'SW2-BR', 'p5', 'SV2', 'eth0.20'
    bdlink 'HYP1-vSW1-BR', 'p5', 'VM2', 'eth0.30'
    bdlink 'SW2-BR', 'p6', 'SV2', 'eth0.30'
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
      support 'target-L3', 'R1-GRT'
      support 'target-L3', 'R2-GRT'
    end
    node 'R1-GRT' do
      term_point 'p1' do
        support 'target-L2', 'R1-GRT', 'p1'
      end
      term_point 'p2' do
        support 'target-L2', 'R1-GRT', 'p1'
      end
      support 'target-L2', 'R1-GRT'
    end
    node 'R2-GRT' do
      term_point 'p1' do
        support 'target-L2', 'R2-GRT', 'p1'
      end
      term_point 'p2' do
        support 'target-L2', 'R2-GRT', 'p1'
      end
      support 'target-L2', 'R2-GRT'
    end
    node 'Seg.A' do
      (0..2).each{|n| term_point "p#{n}"}
      term_point 'p3' do
        support 'target-L2', 'HYP1-vSW1-BR', 'p3'
      end
      term_point 'p4' do
        support 'target-L2', 'SW2-BR', 'p4'
      end
      support 'target-L2', 'R1-BR'
      support 'target-L2', 'R2-BR'
      support 'target-L2', 'SW1-BR'
      support 'target-L2', 'SW2-BR'
      support 'target-L2', 'HYP1-vSW1-BR'
    end
    node 'Seg.B' do
      (0..2).each{|n| term_point "p#{n}"}
      term_point 'p3' do
        support 'target-L2', 'HYP1-vSW1-BR', 'p3'
      end
      term_point 'p4' do
        support 'target-L2', 'SW2-BR', 'p5'
      end
      support 'target-L2', 'R1-BR'
      support 'target-L2', 'R2-BR'
      support 'target-L2', 'SW1-BR'
      support 'target-L2', 'SW2-BR'
      support 'target-L2', 'HYP1-vSW1-BR'
    end
    node 'Seg.C' do
      term_point 'p1' do
        support 'target-L2', 'HYP1-vSW1-BR', 'p4'
      end
      term_point 'p2' do
        support 'target-L2', 'SW2-BR', 'p6'
      end
      support 'target-L2', 'SW1-BR'
      support 'target-L2', 'SW2-BR'
      support 'target-L2', 'HYP1-vSW1-BR'
    end
    node 'VM1' do
      term_point 'eth0' do
        support 'target-L2', 'VM1', 'eth0'
      end
      support 'target-L2', 'VM1'
    end
    node 'VM2' do
      term_point 'eth0.20' do
        support 'target-L2', 'VM2', 'eth0.20'
      end
      term_point 'eth0.30' do
        support 'target-L2', 'VM2', 'eth0.30'
      end
      support 'target-L2', 'VM2'
    end
    node 'SV1' do
      term_point 'eth0' do
        support 'target-L2', 'SV1', 'eth0'
      end
      support 'target-L2', 'SV1'
    end
    node 'SV2' do
      term_point 'eth0.20' do
        support 'target-L2', 'SV2', 'eth0.20'
      end
      term_point 'eth0.30' do
        support 'target-L2', 'SV2', 'eth0.30'
      end
      support 'target-L2', 'SV2'
    end
    bdlink 'GRT-vRT', 'p1', 'Seg.A', 'p0'
    bdlink 'GRT-vRT', 'p2', 'Seg.B', 'p0'
    bdlink 'R1-GRT', 'p1', 'Seg.A', 'p1'
    bdlink 'R1-GRT', 'p2', 'Seg.B', 'p1'
    bdlink 'R2-GRT', 'p1', 'Seg.A', 'p2'
    bdlink 'R2-GRT', 'p2', 'Seg.B', 'p2'
    bdlink 'Seg.A', 'p3', 'VM1', 'eth0'
    bdlink 'Seg.B', 'p3', 'VM2', 'eth0.20'
    bdlink 'Seg.A', 'p4', 'SV1', 'eth0'
    bdlink 'Seg.B', 'p4', 'SV2', 'eth0.20'
    bdlink 'VM2', 'eth0.30', 'Seg.C', 'p1'
    bdlink 'SV2', 'eth0.30', 'Seg.C', 'p2'
  end
end

puts JSON.pretty_generate(nws.topo_data)
