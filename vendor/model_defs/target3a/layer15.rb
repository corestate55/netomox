require 'netomox'

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def register_target_layer15(nws)
  nws.register do
    network 'target-L1.5' do
      support 'target-L1'

      node 'R1' do
        term_point 'Po1' do
          support %w[target-L1 R1 Fa0]
          support %w[target-L1 R1 Fa1]
        end
        support %w[target-L1 R1]
      end

      node 'R2' do
        term_point 'Po1' do
          support %w[target-L1 R2 Fa0]
          support %w[target-L1 R2 Fa1]
        end
        support %w[target-L1 R2]
      end

      bdlink %w[R1 Po1 R2 Po1]

      node 'HYP1-vSW1' do
        term_point 'eth0' do
          support %w[target-L1 HYP1 eth0]
        end
        term_point 'eth1' do
          support %w[target-L1 HYP1 eth1]
        end
        (1..2).each { |n| term_point "p#{n}" }
        support %w[target-L1 HYP1]
      end

      node 'VM1' do
        term_point 'eth0'
        support %w[target-L1 HYP1]
      end

      node 'VM2' do
        term_point 'eth0'
        support %w[target-L1 HYP1]
      end

      bdlink %w[HYP1-vSW1 p1 VM1 eth0]
      bdlink %w[HYP1-vSW1 p2 VM2 eth0]
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize
