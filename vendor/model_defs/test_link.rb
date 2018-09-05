require 'json'
require 'netomox'

model_dir = 'model/'

# test data for node diff
# TODO: tets same link-id different source/destination object

test_link1 = Netomox::DSL::Networks.new do
  network 'layerX' do
    type Netomox::DSL::NWTYPE_L2

    bdlink %w[kept1 p1 kept2 p1]
    bdlink %w[deleted1 p1 deleted2 p1]

    bdlink %w[link_support_kept p1 kept2 p2] do
      support %w[foo a,b,c,d]
      support %w[bar a,b,c,d]
    end
    bdlink %w[link_support_added p1 added2 p2] do
      support %w[bar a,b,c,d]
    end
    bdlink %w[link_support_deleted p1 deleted2 p2] do
      support %w[foo a,b,c,d]
      support %w[bar a,b,c,d]
    end
    bdlink %w[link_support_changed p1 changed2 p2] do
      support %w[foo a,b,c,d]
      support %w[bar a,b,c,d]
    end
  end
end

test_link2 = Netomox::DSL::Networks.new do
  network 'layerX' do
    type Netomox::DSL::NWTYPE_L2

    bdlink %w[kept1 p1 kept2 p1]
    bdlink %w[added1 p1 added p1]

    bdlink %w[link_support_kept p1 kept2 p2] do
      support %w[foo a,b,c,d]
      support %w[bar a,b,c,d]
    end
    bdlink %w[link_support_added p1 added2 p2] do
      support %w[foo a,b,c,d]
      support %w[bar a,b,c,d]
    end
    bdlink %w[link_support_deleted p1 deleted2 p2] do
      support %w[foo a,b,c,d]
    end
    bdlink %w[link_support_changed p1 changed2 p2] do
      support %w[foo a,b,cc,dd]
      support %w[bar a,b,c,d]
    end
  end
end

File.open("#{model_dir}/test_link1.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_link1.topo_data))
end

File.open("#{model_dir}/test_link2.json", 'w') do |file|
  file.write(JSON.pretty_generate(test_link2.topo_data))
end
