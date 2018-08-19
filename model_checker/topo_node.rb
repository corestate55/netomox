require_relative 'topo_const'
require_relative 'topo_tp'
require_relative 'topo_support_node'
require_relative 'topo_node_attr'

module TopoChecker
  # Node for topology data
  class Node
    attr_reader :name, :path, :termination_points, :supporting_nodes, :attribute
    alias supports supporting_nodes

    def initialize(data, parent_path)
      @name = data['node-id']
      @path = [parent_path, @name].join('/')
      setup_termination_points(data)
      setup_supporting_nodes(data)
      setup_attribute(data)
    end

    def eql?(other)
      # for Nodes#-()
      @name == other.name
    end

    def -(other)
      diff_tp(other)
      diff_supports(other)
      diff_attribute(other)
    end

    def to_s
      "node:#{@name}"
    end

    private

    def diff_attribute(other)
      puts '  - node attribute'
      result = if @attribute == other.attribute
                 :kept
               elsif @attribute.empty?
                 :added
               elsif other.attribute.empty?
                 :deleted
               else
                 :changed
               end
      puts "    - #{result}: #{@attribute} => #{other.attribute}"
    end

    def diff_tp(other)
      deleted_tps = @termination_points - other.termination_points
      added_tps = other.termination_points - @termination_points
      kept_tps = @termination_points & other.termination_points
      puts '  - term points'
      puts "    - deleted tps: #{deleted_tps.map(&:to_s)}"
      puts "    - added   tps: #{added_tps.map(&:to_s)}"
      puts "    - kept    tps: #{kept_tps.map(&:to_s)}"
      diff_kept_tps(kept_tps, other)
    end

    # rubocop:disable Lint/Void
    def diff_kept_tps(kept_tps, other)
      kept_tps.each do |tp|
        lhs_tp = @termination_points.find { |t| t.eql?(tp) }
        rhs_tp = other.termination_points.find { |t| t.eql?(tp) }
        puts "    ## check #{lhs_tp}--#{rhs_tp} : changed or not"
        lhs_tp - rhs_tp # TODO: Lint/Void
      end
    end
    # rubocop:enable Lint/Void

    def diff_supports(other)
      deleted_snodes = @supporting_nodes - other.supports
      added_snodes = other.supports - @supporting_nodes
      kept_snodes = @supporting_nodes & other.supports
      puts '  - supporting nodes'
      puts "    - deleted sup-tps: #{deleted_snodes.map(&:to_s)}"
      puts "    - added   sup-tps: #{added_snodes.map(&:to_s)}"
      puts "    - kept    sup-tps: #{kept_snodes.map(&:to_s)}"
    end

    def setup_attribute(data)
      l2node_attr_key = "#{NS_L2NW}:l2-node-attributes"
      l3node_attr_key = "#{NS_L3NW}:l3-node-attributes"
      # NOTICE: WITHOUT network type check
      @attribute = if data.key?(l2node_attr_key)
                     L2NodeAttribute.new(data[l2node_attr_key])
                   elsif data.key?(l3node_attr_key)
                     L3NodeAttribute.new(data[l3node_attr_key])
                   else
                     {}
                   end
    end

    def setup_supporting_nodes(data)
      @supporting_nodes = []
      return unless data.key?('supporting-node')
      @supporting_nodes = data['supporting-node'].map do |snode|
        SupportingNode.new(snode)
      end
    end

    def setup_termination_points(data)
      @termination_points = []
      @termination_points = data["#{NS_TOPO}:termination-point"].map do |tp|
        create_termination_point(tp)
      end
    end

    def create_termination_point(data)
      TerminationPoint.new(data, @path)
    end
  end
end
