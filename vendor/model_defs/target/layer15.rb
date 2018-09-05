require 'netomox'

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
def make_target_layer15
  Netomox::DSL::Network.new 'target-L1.5' do
    support 'target-L1'

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
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize
