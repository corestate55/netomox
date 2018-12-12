require 'netomox'

# rubocop:disable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
def register_target_layer2(nws)
  nws.register do
    network 'target-L2' do
      type Netomox::NWTYPE_L2
      support 'target-L1'
      support 'target-L1.5'
      attribute(
        name: 'L2 of target network',
        flags: ['layer2']
      )

      vlan_a = { id: 10, name: 'Seg.A' }
      vlan_b = { id: 20, name: 'Seg.B' }
      vlan_c = { id: 30, name: 'Seg.C' }
      trunk_vlan_ab = {
        eth_encap: '802.1q',
        vlan_id_names: [vlan_a, vlan_b]
      }
      trunk_vlan_abc = {
        eth_encap: '802.1q',
        vlan_id_names: [vlan_a, vlan_b, vlan_c]
      }
      access_vlan_a = {
        port_vlan_id: 10,
        vlan_id_names: [vlan_a]
      }
      trunk_vlan_b = {
        eth_encap: '802.1q',
        vlan_id_names: [vlan_b]
      }
      trunk_vlan_c = {
        eth_encap: '802.1q',
        vlan_id_names: [vlan_c]
      }

      node 'R1-GRT' do
        attribute(
          name: 'R1-GRT',
          descr: 'L2 of R1-GRT',
          mgmt_addrs: %w[192.168.10.253 192.168.20.253],
          mgmt_vid: 10
        )
        term_point 'p1' do
          attribute(trunk_vlan_ab)
        end
        support %w[target-L1.5 R1]
      end

      node 'R1-BR' do
        term_point 'p1' do
          attribute(trunk_vlan_ab)
        end
        term_point 'p2' do
          attribute(trunk_vlan_ab)
          support %w[target-L1.5 R1 Po1]
        end
        term_point 'p3' do
          attribute(trunk_vlan_ab)
          support %w[target-L1 R1 Fa2]
        end
        support %w[target-L1.5 R1]
      end

      node 'R2-GRT' do
        attribute(
          name: 'R2-GRT',
          descr: 'L2 of R2-GRT',
          mgmt_addrs: %w[192.168.10.252 192.168.20.252],
          mgmt_vid: 10
        )
        term_point 'p1' do
          attribute(trunk_vlan_ab)
        end
        support %w[target-L1.5 R2]
      end

      node 'R2-BR' do
        term_point 'p1' do
          attribute(trunk_vlan_ab)
        end
        term_point 'p2' do
          attribute(trunk_vlan_ab)
          support %w[target-L1.5 R2 Po1]
        end
        term_point 'p3' do
          attribute(trunk_vlan_ab)
          support %w[target-L1 R2 Fa2]
        end
        support %w[target-L1.5 R2]
      end

      node 'SW1-BR' do
        attribute(
          name: 'SW1-BR',
          descr: 'L2 bridge of SW1',
          mgmt_addrs: %w[192.168.10.1],
          mgmt_vid: 10
        )
        term_point 'p1' do
          attribute(trunk_vlan_ab)
          support %w[target-L1 SW1 Fa1]
        end
        term_point 'p2' do
          attribute(trunk_vlan_abc)
          support %w[target-L1 SW1 Fa0]
        end
        term_point 'p3' do
          attribute(trunk_vlan_abc)
          support %w[target-L1 SW1 Fa2]
        end
        support %w[target-L1 SW1]
      end

      node 'SW2-BR' do
        attribute(
          name: 'SW2-BR',
          descr: 'L2 bridge of SW2',
          mgmt_addrs: %w[192.168.10.2],
          mgmt_vid: 10
        )
        term_point 'p1' do
          attribute(trunk_vlan_ab)
          support %w[target-L1 SW2 Fa1]
        end
        term_point 'p2' do
          attribute(trunk_vlan_abc)
          support %w[target-L1 SW2 Fa0]
        end
        term_point 'p3' do
          attribute(trunk_vlan_abc)
          support %w[target-L1 SW2 Fa2]
        end
        term_point 'p4' do
          attribute(access_vlan_a)
          support %w[target-L1 SW2 Fa3]
        end
        term_point 'p5' do
          attribute(trunk_vlan_b)
          support %w[target-L1 SW2 Fa4]
        end
        term_point 'p6' do
          attribute(trunk_vlan_c)
          support %w[target-L1 SW2 Fa4]
        end
        support %w[target-L1 SW2]
      end

      node 'HYP1-vSW1-BR' do
        term_point 'p1' do
          attribute(trunk_vlan_abc)
          support %w[target-L1.5 HYP1-vSW1 eth0]
        end
        term_point 'p2' do
          attribute(trunk_vlan_abc)
          support %w[target-L1.5 HYP1-vSW1 eth1]
        end
        term_point 'p3' do
          attribute(access_vlan_a)
          support %w[target-L1.5 HYP1-vSW1 p1]
        end
        term_point 'p4' do
          attribute(trunk_vlan_b)
          support %w[target-L1.5 HYP1-vSW1 p2]
        end
        term_point 'p5' do
          attribute(trunk_vlan_c)
          support %w[target-L1.5 HYP1-vSW1 p2]
        end
        support %w[target-L1.5 HYP1-vSW1]
      end

      node 'VM1' do
        term_point 'eth0' do
          attribute(access_vlan_a)
          support %w[target-L1.5 VM1 eth0]
        end
        support %w[target-L1.5 VM1]
      end

      node 'VM2' do
        term_point 'eth0.20' do
          attribute(trunk_vlan_b)
          support %w[target-L1.5 VM2 eth0]
        end
        term_point 'eth0.30' do
          attribute(trunk_vlan_c)
          support %w[target-L1.5 VM2 eth0]
        end
        support %w[target-L1.5 VM2]
      end

      node 'SV1' do
        term_point 'eth0' do
          attribute(access_vlan_a)
          support %w[target-L1 SV1 eth0]
        end
        support %w[target-L1 SV1]
      end

      node 'SV2' do
        term_point 'eth0.20' do
          attribute(trunk_vlan_b)
          support %w[target-L1 SV2 eth0]
        end
        term_point 'eth0.30' do
          attribute(trunk_vlan_c)
          support %w[target-L1 SV2 eth0]
        end
        support %w[target-L1 SV2]
      end

      bdlink %w[R1-GRT p1 R1-BR p1]
      bdlink %w[R2-GRT p1 R2-BR p1]
      bdlink %w[R1-BR p2 R2-BR p2]
      # support %w[target-L1 R1,Po1,R2,Po1]
      bdlink %w[R1-BR p3 SW1-BR p1]
      # support %w[target-L1 R1,Fa2,SW1,Fa1]
      bdlink %w[R2-BR p3 SW2-BR p1]
      # support %w[target-L1 R2,Fa2,SW2,Fa1]
      bdlink %w[SW1-BR p2 SW2-BR p2]
      # support %w[target-L1 SW1,Fa0,SW2,Fa0]
      bdlink %w[SW1-BR p3 HYP1-vSW1-BR p1]
      # support %w[target-L1 SW1,Fa2,HYP1,eth0]
      bdlink %w[SW2-BR p3 HYP1-vSW1-BR p2]
      # support %w[target-L1 SW2,Fa2,HYP1,eth1]
      bdlink %w[SW2-BR p4 SV1 eth0]
      # support %w[target-L1 SW2,Fa3,SV1,eth0]
      bdlink %w[HYP1-vSW1-BR p3 VM1 eth0]
      bdlink %w[HYP1-vSW1-BR p4 VM2 eth0.20]
      bdlink %w[SW2-BR p5 SV2 eth0.20]
      bdlink %w[HYP1-vSW1-BR p5 VM2 eth0.30]
      bdlink %w[SW2-BR p6 SV2 eth0.30]
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
