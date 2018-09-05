require 'netomox'

# rubocop:disable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
def make_target_layer2
  Netomox::DSL::Network.new 'target-L2' do
    type Netomox::DSL::NWTYPE_L2
    support 'target-L1'
    support 'target-L1.5'
    attribute(
      name: 'L2 of target network',
      flags: ['layer2']
    )

    vlan_a = { id: 10, name: 'Seg.A' }
    vlan_b = { id: 20, name: 'Seg.B' }
    access_vlan_a = {
      port_vlan_id: 10,
      vlan_id_names: [vlan_a]
    }
    access_vlan_b = {
      port_vlan_id: 20,
      vlan_id_names: [vlan_b]
    }

    node 'R1-GRT' do
      attribute(
        name: 'R1-GRT',
        descr: 'L2 of R1-GRT',
        mgmt_addrs: %w[192.168.10.253 192.168.20.253],
        mgmt_vid: 10
      )
      term_point 'p1' do
        attribute(access_vlan_a)
      end
      term_point 'p2' do
        attribute(access_vlan_b)
      end
      support %w[target-L1 R1]
    end

    node 'R1-BR-VL10' do
      term_point 'p1' do
        attribute(access_vlan_a)
      end
      term_point 'p2' do
        support %w[target-L1 R1 Po1]
      end
      term_point 'p3' do
        support %w[target-L1 R1 Fa2]
      end
      support %w[target-L1 R1]
    end

    node 'R1-BR-VL20' do
      term_point 'p1' do
        attribute(access_vlan_b)
      end
      term_point 'p2' do
        support %w[target-L1 R1 Po1]
      end
      term_point 'p3' do
        support %w[target-L1 R1 Fa2]
      end
      support %w[target-L1 R1]
    end

    node 'R2-GRT' do
      attribute(
        name: 'R2-GRT',
        descr: 'L2 of R2-GRT',
        mgmt_addrs: %w[192.168.10.252 192.168.20.252],
        mgmt_vid: 10
      )
      term_point 'p1'
      term_point 'p2'
      support %w[target-L1 R2]
    end
    node 'R2-BR-VL10' do
      term_point 'p1'
      term_point 'p2' do
        support %w[target-L1 R2 Po1]
      end
      term_point 'p3' do
        support %w[target-L1 R2 Fa2]
      end
      support %w[target-L1 R2]
    end
    node 'R2-BR-VL20' do
      term_point 'p1'
      term_point 'p2' do
        support %w[target-L1 R2 Po1]
      end
      term_point 'p3' do
        support %w[target-L1 R2 Fa2]
      end
      support %w[target-L1 R2]
    end

    node 'SW1-BR-VL10' do
      term_point 'p1' do
        support %w[target-L1 SW1 Fa1]
      end
      term_point 'p2' do
        support %w[target-L1 SW1 Fa0]
      end
      term_point 'p3' do
        support %w[target-L1 SW1 Fa2]
      end
      support %w[target-L1 SW1]
    end

    node 'SW1-BR-VL20' do
      term_point 'p1' do
        support %w[target-L1 SW1 Fa1]
      end
      term_point 'p2' do
        support %w[target-L1 SW1 Fa0]
      end
      term_point 'p3' do
        support %w[target-L1 SW1 Fa2]
      end
      support %w[target-L1 SW1]
    end

    node 'SW1-BR-VL30' do
      term_point 'p1' do
        support %w[target-L1 SW1 Fa2]
      end
      term_point 'p2' do
        support %w[target-L1 SW1 Fa0]
      end
      support %w[target-L1 SW1]
    end

    node 'SW2-BR-VL10' do
      term_point 'p1' do
        support %w[target-L1 SW2 Fa1]
      end
      term_point 'p2' do
        support %w[target-L1 SW2 Fa0]
      end
      term_point 'p3' do
        support %w[target-L1 SW2 Fa2]
      end
      term_point 'p4' do
        support %w[target-L1 SW2 Fa3]
      end
      support %w[target-L1 SW2]
    end

    node 'SW2-BR-VL20' do
      term_point 'p1' do
        support %w[target-L1 SW2 Fa1]
      end
      term_point 'p2' do
        support %w[target-L1 SW2 Fa0]
      end
      term_point 'p3' do
        support %w[target-L1 SW2 Fa2]
      end
      term_point 'p4' do
        support %w[target-L1 SW2 Fa4]
      end
      support %w[target-L1 SW2]
    end
    node 'SW2-BR-VL30' do
      term_point 'p1' do
        support %w[target-L1 SW2 Fa2]
      end
      term_point 'p2' do
        support %w[target-L1 SW2 Fa0]
      end
      term_point 'p3' do
        support %w[target-L1 SW2 Fa4]
      end
      support %w[target-L1 SW2]
    end

    node 'HYP1-vSW1-BR-VL10' do
      term_point 'p1' do
        support %w[target-L1.5 HYP1-vSW1 eth0]
      end
      term_point 'p2' do
        support %w[target-L1.5 HYP1-vSW1 eth1]
      end
      term_point 'p3' do
        support %w[target-L1.5 HYP1-vSW1 p1]
      end
      support %w[target-L1.5 HYP1-vSW1]
    end

    node 'HYP1-vSW1-BR-VL20' do
      term_point 'p1' do
        support %w[target-L1.5 HYP1-vSW1 eth0]
      end
      term_point 'p2' do
        support %w[target-L1.5 HYP1-vSW1 eth1]
      end
      term_point 'p3' do
        support %w[target-L1.5 HYP1-vSW1 p2]
      end
      support %w[target-L1.5 HYP1-vSW1]
    end

    node 'HYP1-vSW1-BR-VL30' do
      term_point 'p1' do
        support %w[target-L1.5 HYP1-vSW1 eth0]
      end
      term_point 'p2' do
        support %w[target-L1.5 HYP1-vSW1 eth1]
      end
      term_point 'p3' do
        support %w[target-L1.5 HYP1-vSW1 p2]
      end
      support %w[target-L1.5 HYP1-vSW1]
    end

    node 'VM1' do
      term_point 'eth0' do
        support %w[target-L1.5 VM1 eth0]
      end
      support %w[target-L1.5 VM1]
    end

    node 'VM2' do
      term_point 'eth0.20' do
        support %w[target-L1.5 VM2 eth0]
      end
      term_point 'eth0.30' do
        support %w[target-L1.5 VM2 eth0]
      end
      support %w[target-L1.5 VM2]
    end

    node 'SV1' do
      term_point 'eth0' do
        support %w[target-L1 SV1 eth0]
      end
      support %w[target-L1 SV1]
    end

    node 'SV2' do
      term_point 'eth0.20' do
        support %w[target-L1 SV2 eth0]
      end
      term_point 'eth0.30' do
        support %w[target-L1 SV2 eth0]
      end
      support %w[target-L1 SV2]
    end

    bdlink %w[R1-GRT p1 R1-BR-VL10 p1]
    bdlink %w[R1-GRT p2 R1-BR-VL20 p1]
    bdlink %w[R2-GRT p1 R2-BR-VL10 p1]
    bdlink %w[R2-GRT p2 R2-BR-VL20 p1]
    bdlink %w[R1-BR-VL10 p2 R2-BR-VL10 p2]
    # support %w[target-L1 R1,Po1,R2,Po1]
    bdlink %w[R1-BR-VL20 p2 R2-BR-VL20 p2]
    # support %w[target-L1 R1,Po1,R2,Po1]
    bdlink %w[R1-BR-VL10 p3 SW1-BR-VL10 p1]
    # support %w[target-L1 R1,Fa2,SW1,Fa1]
    bdlink %w[R1-BR-VL20 p3 SW1-BR-VL20 p1]
    # support %w[target-L1 R1,Fa2,SW1,Fa1]
    bdlink %w[R2-BR-VL10 p3 SW2-BR-VL10 p1]
    # support %w[target-L1 R2,Fa2,SW2,Fa1]
    bdlink %w[R2-BR-VL20 p3 SW2-BR-VL20 p1]
    # support %w[target-L1 R2,Fa2,SW2,Fa1]
    bdlink %w[SW1-BR-VL10 p2 SW2-BR-VL10 p2]
    # support %w[target-L1 SW1,Fa0,SW2,Fa0]
    bdlink %w[SW1-BR-VL20 p2 SW2-BR-VL20 p2]
    # support %w[target-L1 SW1,Fa0,SW2,Fa0]
    bdlink %w[SW1-BR-VL30 p2 SW2-BR-VL30 p2]
    bdlink %w[SW1-BR-VL10 p3 HYP1-vSW1-BR-VL10 p1]
    # support %w[target-L1 SW1,Fa2,HYP1,eth0]
    bdlink %w[SW1-BR-VL20 p3 HYP1-vSW1-BR-VL20 p1]
    # support %w[target-L1 SW1,Fa2,HYP1,eth0]
    bdlink %w[SW2-BR-VL10 p3 HYP1-vSW1-BR-VL10 p2]
    # support %w[target-L1 SW2,Fa2,HYP1,eth1]
    bdlink %w[SW2-BR-VL20 p3 HYP1-vSW1-BR-VL20 p2]
    # support %w[target-L1 SW2,Fa2,HYP1,eth1]
    bdlink %w[SW2-BR-VL10 p4 SV1 eth0]
    # support %w[target-L1 SW2,Fa3,SV1,eth0]
    bdlink %w[SW2-BR-VL20 p4 SV2 eth0.20]
    # support %w[target-L1 SW2,Fa4,SV2,eth0]
    bdlink %w[HYP1-vSW1-BR-VL10 p3 VM1 eth0]
    bdlink %w[HYP1-vSW1-BR-VL20 p3 VM2 eth0.20]
    bdlink %w[SW1-BR-VL30 p1 HYP1-vSW1-BR-VL30 p1]
    bdlink %w[SW2-BR-VL30 p1 HYP1-vSW1-BR-VL30 p2]
    bdlink %w[SW2-BR-VL30 p3 SV2 eth0.30]
    bdlink %w[HYP1-vSW1-BR-VL30 p3 VM2 eth0.30]
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
