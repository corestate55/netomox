# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/error'
require 'netomox/dsl/base'
require 'netomox/dsl/network_attr_rfc'
require 'netomox/dsl/network_attr_ops'
require 'netomox/dsl/network_attr_mddo'
require 'netomox/dsl/node'
require 'netomox/dsl/link'

module Netomox
  module DSL
    # supporting network container
    class SupportNetwork
      # @param [String] nw_ref Network name
      def initialize(nw_ref)
        @nw_ref = nw_ref
      end

      # @return [String]
      def path
        @nw_ref
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        { 'network-ref' => @nw_ref }
      end
    end

    # rubocop:disable Metrics/ClassLength
    # network, node and link container
    class Network < DSLObjectBase
      # @!attribute [rw] nodes
      #   @return [Array<Node>]
      # @!attribute [rw] links
      #   @return [Array<Link>]
      # @!attribute [rw] supports
      #   @return [Array<SupportNetwork>]
      attr_accessor :nodes, :links, :supports

      # @param [Networks] parent Parent object (Networks)
      # @param [String] name Network name
      # @param [Proc] block Code block to eval this instance
      def initialize(parent, name, &block)
        super(parent, name)
        @type = {}
        @nodes = []
        @links = []
        @supports = [] # supporting network
        @attribute = {} # for augments
        register(&block) if block_given?
      end

      # @param [Hash] type Network type object
      def type(type = nil)
        if type
          @type[type] = {} ## TODO recursive type definition
        else
          @type # called as attr_reader
        end
      end

      # Add supporting network
      # @param [String] nw_ref Network name
      def support(nw_ref)
        snw = find_support(nw_ref)
        if snw
          Netomox.logger.debug "Ignore: Duplicated support definition:#{snw.path} in #{@path}"
        else
          @supports.push(SupportNetwork.new(nw_ref))
        end
      end

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize

      # Set attribute
      # @param [Hash] attr Attribute data
      def attribute(attr)
        @attribute = {}
        @type.key?(NWTYPE_L2) && (@attribute = L2NWAttribute.new(**attr))
        @type.key?(NWTYPE_L3) && (@attribute = L3NWAttribute.new(**attr))
        @type.key?(NWTYPE_OPS) && (@attribute = OpsNWAttribute.new(**attr))
        @type.key?(NWTYPE_MDDO_L1) && (@attribute = MddoL1NWAttribute.new(**attr))
        @type.key?(NWTYPE_MDDO_L2) && (@attribute = MddoL2NWAttribute.new(**attr))
        @type.key?(NWTYPE_MDDO_L3) && (@attribute = MddoL3NWAttribute.new(**attr))
        @type.key?(NWTYPE_MDDO_OSPF_AREA) && (@attribute = MddoOspfAreaNWAttribute.new(**attr))
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize

      # Add or get node
      # @param [String] name Node name
      # @param [Proc] block Code block to eval the node
      # @return [Node]
      def node(name, &block)
        node = find_node(name)
        if node
          node.register(&block) if block_given?
        else
          node = Node.new(self, name, &block)
          @nodes.push(node)
        end
        node
      end

      # make uni-directional link
      # @param [String, Array<String>] src_node Source node name or Array [src_node, src_tp, dst_node, dst_tp]
      # @param [String] src_tp Source term-point name
      # @param [String] dst_node Destination node name
      # @param [String] dst_tp Destination term-point name
      # @param [Proc] block Code block to eval the link
      # @return [Link]
      def link(src_node, src_tp = nil, dst_node = nil, dst_tp = nil, &block)
        args = normalize_link_args(src_node, src_tp, dst_node, dst_tp)
        link = find_link(args.join(','))
        if link
          link.register(&block) if block_given?
        else
          link = Link.new(self, args[0], args[1], args[2], args[3], &block)
          @links.push(link)
        end
        link
      end

      # make bi-directional link
      # @param [String, Array<String>] src_node Source node name or Array [src_node, src_tp, dst_node, dst_tp]
      # @param [String] src_tp Source term-point name
      # @param [String] dst_node Destination node name
      # @param [String] dst_tp Destination term-point name
      # @param [Proc] block Code block to eval the link
      # @todo: supporting-link implementation
      def bdlink(src_node, src_tp = nil, dst_node = nil, dst_tp = nil, &block)
        args = normalize_link_args(src_node, src_tp, dst_node, dst_tp)
        link(args[0], args[1], args[2], args[3], &block)
        link(args[2], args[3], args[0], args[1], &block)
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        data = {
          'network-id' => @name,
          'network-types' => @type,
          'node' => @nodes.map(&:topo_data),
          "#{NS_TOPO}:link" => @links.map(&:topo_data)
        }
        data['supporting-network'] = @supports.map(&:topo_data) unless @supports.empty?
        data[@attribute.type] = @attribute.topo_data unless @attribute.empty?
        data
      end

      # Find all links that between self and destination
      # @param [String, Array<String>] src_node_name Source node name or Array [src_node, src_tp, dst_node, dst_tp]
      # @param [String] src_tp_name Source term-point name
      # @param [String] dst_node_name Destination node name
      # @param [String] dst_tp_name Destination term-point name
      # @return [Array<Link>]
      def links_between(src_node_name:, dst_node_name:, src_tp_name: nil, dst_tp_name: nil)
        conds = normalize_find_link_args(
          src_node_name: src_node_name, src_tp_name: src_tp_name,
          dst_node_name: dst_node_name, dst_tp_name: dst_tp_name
        )
        found_links = find_links_with_condition(conds)
        conds = normalize_find_link_args(
          dst_node_name: src_node_name, dst_tp_name: src_tp_name,
          src_node_name: dst_node_name, src_tp_name: dst_tp_name
        )
        found_links.concat(find_links_with_condition(conds))
      end

      # Find node by name
      # @param [String] name Node name
      # @return [Node, nil] Found node (nil if not found)
      def find_node(name)
        @nodes.find { |node| node.name == name }
      end

      # Find link by name
      # @param [String] name Link name
      # @return [Link, nil] Found link (nil if not found)
      def find_link(name)
        @links.find { |link| link.name == name }
      end

      # Find supporting network
      # @param [String] nw_ref Network name
      # @return [SupportNetwork, nil] Found supporting network (nil if not found)
      def find_support(nw_ref)
        @supports.find { |snw| snw.path == nw_ref }
      end

      # Sort nodes by name
      # @return [Array<Node>]
      def sort_node_by_name
        @nodes.sort do |node_a, node_b|
          ret = node_a.name.casecmp(node_b.name)
          ret.zero? ? node_a.name <=> node_b.name : ret
        end
      end

      # Sort nodes by name (overwrite)
      # @return [Array<Node>]
      def sort_node_by_name!
        nodes = sort_node_by_name
        @nodes = nodes
      end

      private

      # Find all links src/dst and node/tp name match.
      # @param [Array<Array<String>>] conds Match conditions
      # @return [Array<Link>] Found links (Empty array if not found)
      def find_links_with_condition(conds)
        @links.find_all do |link|
          conds.inject(true) do |res, cond|
            res && link.send(cond[0]).send(cond[1]) == cond[2]
          end
        end
      end

      # construct link search conditions to input
      #   condition = [method1 method2 match_value]
      # @param [String] src_node_name Source node name
      # @param [String] dst_node_name Destination node name
      # @param [String] src_tp_name Source term-point name
      # @param [String] dst_tp_name Destination term-point name
      # @return [Array<Array<String>>] Array of condition
      # @see find_links_with_conditions
      def normalize_find_link_args(src_node_name:, dst_node_name:, src_tp_name: false, dst_tp_name: false)
        conds = []
        conds.push(%W[source node_ref #{src_node_name}])
        conds.push(%W[source tp_ref #{src_tp_name}]) if src_tp_name
        conds.push(%W[destination node_ref #{dst_node_name}])
        conds.push(%W[destination tp_ref #{dst_tp_name}]) if dst_tp_name
        conds
      end

      # Normalize path (elements or array of elements) to array
      # @param [String, Array<String>] src_node Source node name or Array [src_node, src_tp, dst_node, dst_tp]
      # @param [String] src_tp Source term-point name
      # @param [String] dst_node Destination node name
      # @param [String] dst_tp Destination term-point name
      # @return [Array<String>]
      # @raise [DSLInvalidArgumentError]
      def normalize_link_args(src_node, src_tp = nil, dst_node = nil, dst_tp = nil)
        # with 1 arg (an array)
        return src_node if src_node.is_a?(Array) && check_normalize_args(src_node, 4)

        # with 4 args
        args = [src_node, src_tp, dst_node, dst_tp]
        return args if check_normalize_args(args, 4)

        raise DSLInvalidArgumentError, 'Link args is not satisfied: ' \
                                       "src: { node:#{src_node}, tp:#{src_tp}}, dst: { node:#{dst_node}, tp:#{dst_tp} }"
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
