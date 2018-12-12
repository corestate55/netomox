require 'netomox'

# rubocop:disable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
def register_target_layer35(nws)
  nws.register do
    network 'target-L3.5' do
      type Netomox::NWTYPE_L3
      support 'target-L3'
      attribute(
        name: 'L3.5 of target network',
        flags: %w[layer3 unicast]
      )

      seg_a_prefix = { prefix: '192.168,10.0/24', metric: 100 }
      seg_b_prefix = { prefix: '192.168.20.0/24', metric: 100 }

      node 'GRT-vRT' do
        attribute(
          prefixes: [seg_a_prefix, seg_b_prefix],
          flags: %w[fhrp-virtual-router default-gateway pseudo-node]
        )
        term_point 'p1' do
          attribute(ip_addrs: ['192.168.10.254'])
          support %w[target-L3 R1-GRT p1]
          support %w[target-L3 R2-GRT p1]
        end
        term_point 'p2' do
          attribute(ip_addrs: ['192.168.20.254'])
          support %w[target-L3 R1-GRT p2]
          support %w[target-L3 R2-GRT p2]
        end
        support %w[target-L3 R1-GRT]
        support %w[target-L3 R2-GRT]
      end

      node 'Seg.A' do
        term_point 'p0'
        support %w[target-L3 Seg.A]
      end

      node 'Seg.B' do
        term_point 'p0'
        support %w[target-L3 Seg.B]
      end

      bdlink %w[GRT-vRT p1 Seg.A p0]
      bdlink %w[GRT-vRT p2 Seg.B p0]
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
