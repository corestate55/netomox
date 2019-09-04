# frozen_string_literal: true

RSpec.describe 'check node-tp support path consistency', :checkup do
  def get_message(result, index)
    result[:messages][index][:message]
  end

  before do
    nws_def = Netomox::DSL::Networks.new do
      network 'nw1' do
        node 'node1a' do
          term_point 'p1'
        end
        node 'node1b' do
          term_point 'p1'
        end
      end
      network 'nw2' do
        node 'node2a' do
          support %w[nw1 node1a]
          term_point 'p1' do
            support %w[nw1 node1a p1]
          end
        end
        node 'node2b' do
          support %w[nw1 node1a]
          term_point 'p1' do
            # support node mismatch
            support %w[nw1 node1b p1]
          end
        end
        node 'node2c' do
          term_point 'p1' do
            # node does not has support, but tp has support.
            support %w[nw1 node1a p1]
          end
        end
      end
    end
    nws = Netomox::Topology::Networks.new(nws_def.topo_data)
    @result = nws.check_family_support_path
  end

  it 'find 2 errors' do
    expect(@result[:messages].length).to eq 2
  end

  it 'finds node-tp support path mismatch' do
    msg = 'node:nw2__node2b does not support same node with tp:nw2__node2b__p1: nw1__node1b'
    expect(get_message(@result, 0)).to eq msg
  end

  it 'finds node does not have support path but tp has support' do
    msg = 'tp:nw2__node2c__p1 has supports but node:nw2__node2c does not have supports'
    expect(get_message(@result, 1)).to eq msg
  end
end
