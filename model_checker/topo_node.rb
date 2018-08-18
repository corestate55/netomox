require_relative 'topo_tp'
require_relative 'topo_support_node'

module TopoChecker
  # Node for topology data
  class Node
    attr_reader :name, :path, :termination_points, :supporting_nodes
    alias_method :supports, :supporting_nodes

    def initialize(data, parent_path)
      @name = data['node-id']
      @path = [parent_path, @name].join('/')
      setup_termination_points(data)

      @supporting_nodes = []
      return unless data.key?('supporting-node')
      @supporting_nodes = data['supporting-node'].map do |snode|
        SupportingNode.new(snode)
      end
    end

    def eql?(other)
      # for Nodes#-()
      @name == other.name
    end

    def -(other)
      deleted_tps = @termination_points - other.termination_points
      added_tps = other.termination_points - @termination_points
      kept_tps = @termination_points & other.termination_points
      puts '  - term points'
      puts "    - deleted tps: #{deleted_tps.map(&:to_s)}"
      puts "    - added   tps: #{added_tps.map(&:to_s)}"
      puts "    - kept    tps: #{kept_tps.map(&:to_s)}"
      kept_tps.each do |tp|
        lhs_tp = @termination_points.find { |t| t.eql?(tp) }
        rhs_tp = other.termination_points.find { |t| t.eql?(tp) }
        puts "    ## check #{lhs_tp}--#{rhs_tp} : changed or not"
        lhs_tp - rhs_tp
      end
      deleted_snodes = @supporting_nodes - other.supports
      added_snodes = other.supports - @supporting_nodes
      kept_snodes = @supporting_nodes & other.supports
      puts '  - supporting nodes'
      puts "    - deleted sup-tps: #{deleted_snodes.map(&:to_s)}"
      puts "    - added   sup-tps: #{added_snodes.map(&:to_s)}"
      puts "    - kept    sup-tps: #{kept_snodes.map(&:to_s)}"
    end

    def to_s
      "node:#{@name}"
    end

    private

    def setup_termination_points(data)
      @termination_points = []
      tp_key = 'ietf-network-topology:termination-point' # alias
      @termination_points = data[tp_key].map do |tp|
        create_termination_point(tp)
      end
    end

    def create_termination_point(data)
      TerminationPoint.new(data, @path)
    end
  end
end
