require 'json'
require 'optparse'
require_relative 'model_checker/topo_networks_ops'
require_relative 'model_checker/graph_networks_ops'

opt = OptionParser.new
option = {}
opt.on('-f', '--file=FILE', 'Target topology data (json)') do |v|
  option[:file] = v
end
opt.on('-c', '--check', 'Run model check') do |v|
  option[:check] = v
end
opt.on('-n', '--neo4j', 'Add data to neo4j') do |v|
  option[:neo4j] = v
end
opt.on('-d', '--debug', 'Debug (dump data)') do |v|
  option[:debug] = v
end
opt.parse!(ARGV)

## read file
data = []
if option[:file]
  data = JSON.parse(File.read(option[:file]))
else
  warn opt.help
  exit 1
end
puts JSON.pretty_generate(data) if option[:debug]

if option[:check]
  networks = TopoChecker::Networks.new(data)
  puts '# check all supporting networks'
  networks.check_all_supporting_networks
  puts '# check all supporting nodes'
  networks.check_all_supporting_nodes
  puts '# check all supporting termination points'
  networks.check_all_supporting_tps
  puts '# check all supporting links'
  networks.check_all_supporting_links
  puts '# check all link pair'
  networks.check_all_link_pair
  puts '# check uniqueness'
  networks.check_object_uniqueness
  puts '# check terminal point reference count'
  networks.check_tp_ref_count
end

if option[:neo4j]
  db_info = JSON.parse(File.read('./db_info.json'), symbolize_names: true)
  networks = TopoChecker::GraphNetworks.new(data, db_info)
  if option[:debug]
    puts '# node objects'
    puts JSON.pretty_generate(networks.node_objects)
    puts '# relationship objects'
    puts JSON.pretty_generate(networks.relationship_objects)
    puts '# DB info'
    puts db_info
    exit(0)
  end
  puts '# clear all nodes'
  networks.exec_clear_all_objects
  puts '# create nodes/relationships'
  networks.exec_create_objects
end
