require_relative '../model_dsl/dsl'

# rubocop:disable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
def make_target_layer3
  NWTopoDSL::Network.new 'target-L3' do
    type NWTopoDSL::NWTYPE_L3
    support 'target-L1'
    support 'target-L1.5'
    support 'target-L2'
    attribute(
      name: 'L3 of target network',
      flags: %w[layer3 unicast]
    )

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
      (0..2).each { |n| term_point "p#{n}" }
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
      (0..2).each { |n| term_point "p#{n}" }
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
# rubocop:enable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
