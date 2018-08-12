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
  File.open(option[:file]) do |file|
    data = JSON.parse(file.read)
  end
else
  warn opt.help
  exit 1
end
puts JSON.pretty_generate(data) if option[:debug]

if option[:check]
  networks = TopoChecker::Networks.new(data)
  p '## check all supporting networks'
  networks.check_all_supporting_networks
  p '## check all supporting nodes'
  networks.check_all_supporting_nodes
  p '## check all supporting termination points'
  networks.check_all_supporting_tps
  p '## check all supporting links'
  networks.check_all_supporting_links
  p '## check all link pair'
  networks.check_all_link_pair
  p '## check uniqueness'
  networks.check_object_uniqueness
  p '## check terminal point reference count'
  networks.check_tp_ref_count
end

if option[:neo4j]
  networks = TopoChecker::GraphNetworks.new(data)
  if option[:debug]
    puts JSON.pretty_generate(networks.node_objects)
    puts JSON.pretty_generate(networks.relationship_objects)
  end
  p 'clear all nodes'
  networks.exec_clear_all_objects
  p 'create nodes/relationships'
  networks.exec_create_objects
end
