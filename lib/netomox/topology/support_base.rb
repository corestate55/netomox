# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # Base class for supporting object reference
    class SupportingRefBase < AttributeBase
      def initialize(attr_table, data)
        super(attr_table, data, 'supporting-base')
        @path = 'support' # TODO: dummy for #to_data
      end

      def to_s
        "support:#{ref_path}"
      end

      def ref_network
        ref_path.split('__').shift
      end

      def ref_link_tp_name
        path_elements = ref_path.split('__')
        path_elements.shift
        path_elements.join(',')
      end

      def ref_path
        @attr_table.int_keys.map { |r| send(r) }.join('__')
      end

      def ref_parent_path
        ref_parents = ref_path.split('__')
        ref_parents.pop
        ref_parents.join('__')
      end
    end

    # Supporting network for network topology data
    class SupportingNetwork < SupportingRefBase
      ATTR_DEFS = [{ int: :network_ref, ext: 'network-ref' }].freeze
      attr_accessor :network_ref

      def initialize(data)
        super(ATTR_DEFS, data)
      end
    end

    # Supporting node for topology node
    class SupportingNode < SupportingRefBase
      ATTR_DEFS = [
        { int: :network_ref, ext: 'network-ref' },
        { int: :node_ref, ext: 'node-ref' }
      ].freeze
      attr_accessor :network_ref, :node_ref

      def initialize(data)
        super(ATTR_DEFS, data)
      end
    end

    # Supporting link for topology link data
    class SupportingLink < SupportingRefBase
      ATTR_DEFS = [
        { int: :network_ref, ext: 'network-ref' },
        { int: :link_ref, ext: 'link-ref' }
      ].freeze
      attr_accessor :network_ref, :link_ref

      def initialize(data)
        super(ATTR_DEFS, data)
      end
    end

    # Supporting termination point for topology termination point
    class SupportingTerminationPoint < SupportingRefBase
      ATTR_DEFS = [
        { int: :network_ref, ext: 'network-ref' },
        { int: :node_ref, ext: 'node-ref' },
        { int: :tp_ref, ext: 'tp-ref' }
      ].freeze
      attr_accessor :network_ref, :node_ref, :tp_ref

      def initialize(data)
        super(ATTR_DEFS, data)
      end
    end
  end
end
