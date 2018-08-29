require 'json'
require 'thor'
require_relative 'model_checker/topo_networks_diff'
require_relative 'model_checker/graph_networks_ops'
require_relative 'model_checker/diff_view'

# network topology model checker (frontend)
class Checker < Thor
  class_option :verbose, type: :boolean, default: false, aliases: :v

  desc 'check JSON', 'Check topology data consistency'
  def check(file)
    run_check(file)
  end

  desc 'diff JSON1 JSON2', 'Diff between topology data'
  option :all, type: :boolean, default: false, aliases: :a
  option :color, type: :boolean, default: false, aliases: :c
  def diff(file1, file2)
    run_diff(file1, file2)
  end

  desc 'graphdb JSON', 'Send topology data to graphdb (neo4j)'
  def graphdb(file)
    run_graphdb(file)
  end

  private

  def open_data(file, opt_hash = {})
    JSON.parse(File.read(file), opt_hash)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def run_check(file)
    data = open_data(file)
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
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def run_graphdb(file)
    data = open_data(file)
    db_info = open_data('./db_info.json', symbolize_names: true)
    networks = TopoChecker::GraphNetworks.new(data, db_info)
    if options[:verbose]
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
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def run_diff(file1, file2)
    data1 = open_data(file1)
    data2 = open_data(file2)
    nws1 = TopoChecker::Networks.new(data1)
    nws2 = TopoChecker::Networks.new(data2)
    d_nws = nws1.diff(nws2)

    # test
    json_str = JSON.pretty_generate(d_nws.to_data)
    opts = {
      data: json_str,
      print_all: options[:all],
      color: options[:color]
    }
    diff_view = TopoChecker::DiffView.new(opts)
    puts diff_view
    return unless options[:verbose]
    puts '-----------------'
    puts json_str
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end

Checker.start(ARGV)
