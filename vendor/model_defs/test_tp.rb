require 'json'
require 'netomox'

model_dir = 'model/'

# test data for termination point diff
# TODO: L2 term point attribute has Array (Array keep/add/del/change)

test_tp1 = Netomox::DSL::Networks.new do
  network 'layerX' do
    type Netomox::DSL::NWTYPE_L2
    node 'nodeX' do
      term_point 'tp_kept'
      term_point 'tp_deleted'

      term_point 'tp_support_kept' do
        support %w[foo bar baz]
        support %w[foo bar hoge]
      end
      term_point 'tp_support_added' do
        support %w[foo bar hoge]
      end
      term_point 'tp_support_deleted' do
        support %w[foo bar baz]
        support %w[foo bar hoge]
      end
      term_point 'tp_support_changed' do
        support %w[foo bar baz]
        support %w[foo bar hoge]
      end
    end
  end
end

test_tp2 = Netomox::DSL::Networks.new do
  network 'layerX' do
    type Netomox::DSL::NWTYPE_L2
    node 'nodeX' do
      term_point 'tp_kept'
      term_point 'tp_added'

      term_point 'tp_support_kept' do
        support %w[foo bar baz]
        support %w[foo bar hoge]
      end
      term_point 'tp_support_added' do
        support %w[foo bar baz]
        support %w[foo bar hoge]
      end
      term_point 'tp_support_deleted' do
        support %w[foo bar baz]
      end
      term_point 'tp_support_changed' do
        support %w[foo bar baz]
        support %w[foo bar hoge_hoge]
      end
    end
  end
end

File.open("#{model_dir}/test_tp1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_tp1.topo_data))
end

File.open("#{model_dir}/test_tp2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_tp2.topo_data))
end
