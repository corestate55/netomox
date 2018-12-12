require 'netomox'

# rubocop:disable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
def register_target_layer1(nws)
  nws.register do
    network 'target-L1' do
      node 'R1' do
        (0..2).each { |n| term_point "Fa#{n}" }
      end

      node 'R2' do
        (0..2).each { |n| term_point "Fa#{n}" }
      end

      node 'SW1' do
        (0..2).each { |n| term_point "Fa#{n}" }
      end

      node 'SW2' do
        (0..4).each { |n| term_point "Fa#{n}" }
      end

      node 'HYP1' do
        (0..1).each { |n| term_point "eth#{n}" }
      end

      node 'SV1' do
        term_point 'eth0'
      end

      node 'SV2' do
        term_point 'eth0'
      end

      bdlink %w[R1 Fa0 R2 Fa0]
      bdlink %w[R1 Fa1 R2 Fa1]
      bdlink %w[R1 Fa2 SW1 Fa1]
      bdlink %w[R2 Fa2 SW2 Fa1]
      bdlink %w[SW1 Fa0 SW2 Fa0]
      bdlink %w[SW1 Fa2 HYP1 eth0]
      bdlink %w[SW2 Fa2 HYP1 eth1]
      bdlink %w[SW2 Fa3 SV1 eth0]
      bdlink %w[SW2 Fa4 SV2 eth0]
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/BlockLength, Metrics/AbcSize
