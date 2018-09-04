require 'json'
require 'thor'
require_relative 'model_checker/topo_networks_ops'
require_relative 'model_checker/graph_networks_ops'
require_relative 'model_checker/diff_view'

# network topology model checker (frontend)
class Checker < Thor
  class_option :verbose, type: :boolean, default: false, aliases: :v

  desc 'check JSON', 'Check topology data consistency'
  def check(file)
    run_check(file)
  end

  desc 'diff [opts] JSON1 JSON2', 'Diff between topology data'
  option :all, type: :boolean, default: false, aliases: :a,
               desc: 'Print all includes unchanged object.'
  option :color, type: :boolean, default: false, aliases: :c,
                 desc: 'Print diff with color.'
  option :output, type: :string, default: nil, aliases: :o,
                  desc: 'Output diff json data to file'
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
    networks = TopoChecker::Networks.new(open_data(file))
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
    db_info = open_data('./db_info.json', symbolize_names: true)
    networks = TopoChecker::GraphNetworks.new(open_data(file), db_info)
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

  def write_diff_file(json_str)
    File.open(options[:output], 'w') do |file|
      file.write(json_str)
    end
  end

  def write_diff_stdout(json_str)
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

  def run_diff(file1, file2)
    nws1 = TopoChecker::Networks.new(open_data(file1))
    nws2 = TopoChecker::Networks.new(open_data(file2))
    d_nws = nws1.diff(nws2)
    json_str = JSON.pretty_generate(d_nws.to_data)
    if options[:output]
      write_diff_file(json_str)
    else
      write_diff_stdout(json_str)
    end
  end
end

Checker.start(ARGV)
