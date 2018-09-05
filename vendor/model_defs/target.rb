require 'json'
require 'netomox'
require_relative 'target/layer1'
require_relative 'target/layer15'
require_relative 'target/layer2'
require_relative 'target/layer3'

nws = Netomox::DSL::Networks.new
nws.networks.push(
  make_target_layer1,
  make_target_layer15,
  make_target_layer2,
  make_target_layer3
)

puts JSON.pretty_generate(nws.topo_data)
