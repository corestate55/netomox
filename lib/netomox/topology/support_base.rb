# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # Base class for supporting object reference
    class SupportingRefBase < AttributeBase
      # @param [Array<Hash>] attr_table Attribute table
      # @param [Hash] data Attribute data in RFC8345
      def initialize(attr_table, data)
        super(attr_table, data, 'supporting-base')
        @path = 'support' # TODO: dummy for #to_data
      end

      # @return [String]
      def to_s
        "support:#{ref_path}"
      end

      # @return [String]
      def ref_network
        ref_path.split('__').shift
      end

      # @return [String, nil]
      def ref_node
        paths = ref_path.split('__')
        paths.length > 1 ? paths[1] : nil
      end

      # @return [String, nil]
      def ref_tp
        paths = ref_path.split('__')
        paths.length > 2 ? paths[2] : nil
      end

      # convert for link-name string ("nw__node__tp" => "node,tp")
      # @return [String]
      def ref_link_tp_name
        path_elements = ref_path.split('__')
        path_elements.shift
        path_elements.join(',')
      end

      # convert to path string ("nw__node__tp")
      # return [String]
      def ref_path
        @attr_table.int_keys.map { |r| send(r) }.join('__')
      end

      # parent path string of referenced object
      # return [String]
      def ref_parent_path
        ref_parents = ref_path.split('__')
        ref_parents.pop
        ref_parents.join('__')
      end
    end

    # Supporting network for network topology data
    class SupportingNetwork < SupportingRefBase
      # @!attribute [rw] network_ref
      #   @return [String]
      attr_accessor :network_ref

      ATTR_DEFS = [{ int: :network_ref, ext: 'network-ref' }].freeze

      # @param [Hash] data Support ref data in RFC834g
      def initialize(data)
        super(ATTR_DEFS, data)
      end
    end

    # Supporting node for topology node
    class SupportingNode < SupportingRefBase
      # @!attribute [rw] network_ref
      #   @return [String]
      # @!attribute [rw] node_ref
      #   @return [String]
      attr_accessor :network_ref, :node_ref

      ATTR_DEFS = [
        { int: :network_ref, ext: 'network-ref' },
        { int: :node_ref, ext: 'node-ref' }
      ].freeze

      # @param [Hash] data Support ref data in RFC834g
      def initialize(data)
        super(ATTR_DEFS, data)
      end
    end

    # Supporting link for topology link data
    class SupportingLink < SupportingRefBase
      # @!attribute [rw] network_ref
      #   @return [String]
      # @!attribute [rw] link_ref
      #   @return [String]
      attr_accessor :network_ref, :link_ref

      ATTR_DEFS = [
        { int: :network_ref, ext: 'network-ref' },
        { int: :link_ref, ext: 'link-ref' }
      ].freeze

      # @param [Hash] data Support ref data in RFC834g
      def initialize(data)
        super(ATTR_DEFS, data)
      end
    end

    # Supporting termination point for topology termination point
    class SupportingTerminationPoint < SupportingRefBase
      # @!attribute [rw] network_ref
      #   @return [String]
      # @!attribute [rw] node_ref
      #   @return [String]
      # @!attribute [rw] tp_ref
      #   @return [String]
      attr_accessor :network_ref, :node_ref, :tp_ref

      ATTR_DEFS = [
        { int: :network_ref, ext: 'network-ref' },
        { int: :node_ref, ext: 'node-ref' },
        { int: :tp_ref, ext: 'tp-ref' }
      ].freeze

      # @param [Hash] data Support ref data in RFC834g
      def initialize(data)
        super(ATTR_DEFS, data)
      end
    end
  end
end
