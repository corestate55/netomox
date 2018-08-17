require_relative '../model_dsl/dsl'

# rubocop:disable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
def make_target_layer2
  NWTopoDSL::Network.new 'target-L2' do
    type NWTopoDSL::NWTYPE_L2
    support 'target-L1'
    support 'target-L1.5'
    attribute(
      name: 'L2 of target network',
      flags: ['layer2']
    )

    node 'R1-GRT' do
      attribute(
        name: 'R1-GRT',
        descr: 'L2 of R1-GRT',
        mgmt_addrs: %w[192.168.10.253 192.168.20.253],
        mgmt_vid: 10
      )
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
      attribute(
        name: 'R2-GRT',
        descr: 'L2 of R2-GRT',
        mgmt_addrs: %w[192.168.10.252 192.168.20.252],
        mgmt_vid: 10
      )
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
      attribute(
        name: 'SW1-BR',
        descr: 'L2 bridge of SW1',
        mgmt_addrs: %w[192.168.10.1],
        mgmt_vid: 10
      )
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
      attribute(
        name: 'SW2-BR',
        descr: 'L2 bridge of SW2',
        mgmt_addrs: %w[192.168.10.2],
        mgmt_vid: 10
      )
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

    bdlink %w[R1-GRT p1 R1-BR p1]
    bdlink %w[R2-GRT p1 R2-BR p1]
    bdlink %w[R1-BR p2 R2-BR p2]
    bdlink %w[R1-BR p3 SW1-BR p1]
    bdlink %w[R2-BR p3 SW2-BR p1]
    bdlink %w[SW1-BR p2 SW2-BR p2]
    bdlink %w[SW1-BR p3 HYP1-vSW1-BR p1]
    bdlink %w[SW2-BR p3 HYP1-vSW1-BR p2]
    bdlink %w[SW2-BR p4 SV1 eth0]
    bdlink %w[HYP1-vSW1-BR p3 VM1 eth0]
    bdlink %w[HYP1-vSW1-BR p4 VM2 eth0.20]
    bdlink %w[SW2-BR p5 SV2 eth0.20]
    bdlink %w[HYP1-vSW1-BR p5 VM2 eth0.30]
    bdlink %w[SW2-BR p6 SV2 eth0.30]
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
