# frozen_string_literal: true

require 'netomox/const'
require 'netomox/topology/link_tpref'
require 'netomox/topology/link_attr/rfc'
require 'netomox/topology/link_attr/mddo'
require 'netomox/topology/base'

module Netomox
  module Topology
    # Link for topology data
    class Link < TopoObjectBase
      # @!attribute [rw] source
      #   @return [TpRef]
      # @!attribute [rw] destination
      #   @return [TpRef]
      attr_accessor :source, :destination

      # Attribute type key and its class for Link
      ATTR_KEY_KLASS_LIST = [
        { key: "#{NS_L2NW}:l2-link-attributes", klass: L2LinkAttribute },
        { key: "#{NS_L3NW}:l3-link-attributes", klass: L3LinkAttribute },
        { key: "#{NS_MDDO}:l1-link-attributes", klass: MddoL1LinkAttribute },
        { key: "#{NS_MDDO}:l2-link-attributes", klass: MddoL2LinkAttribute },
        { key: "#{NS_MDDO}:l3-link-attributes", klass: MddoL3LinkAttribute },
        { key: "#{NS_MDDO}:ospf-area-link-attributes", klass: MddoOspfAreaLinkAttribute },
        { key: "#{NS_MDDO}:bgp-proc-link-attributes", klass: MddoBgpProcLinkAttribute },
        { key: "#{NS_MDDO}:bgp-as-link-attributes", klass: MddoBgpAsLinkAttribute }
      ].freeze

      # @param [Hash] data RFC8345 data (link element)
      # @param [String] parent_path Parent (Network) path
      def initialize(data, parent_path)
        super(data['link-id'], parent_path)

        @source = create_link_edge(data, 'source')
        @destination = create_link_edge(data, 'destination')
        setup_supports(data, 'supporting-link', SupportingLink)
        setup_attribute(data, ATTR_KEY_KLASS_LIST)
        setup_diff_state(data)
      end

      # @param [Link] other Link to compare
      # @return [Link] Result of comparison
      def diff(other)
        # forward check
        d_link = Link.new({ 'link-id' => @name }, @parent_path)
        d_link.source = diff_link_tp(:source, other)
        d_link.destination = diff_link_tp(:destination, other)
        d_link.supports = diff_supports(other)
        d_link.attribute = diff_attribute(other)
        d_link.diff_state = select_diff_state(other)
        # backward check
        d_link.diff_backward_check(%i[source destination supports attribute])
        # return
        d_link
      end

      # @return [void]
      def fill_diff_state
        fill_diff_state_of(%i[source destination supports attribute])
      end

      # @return [String]
      def to_s
        "link:#{name}" # "#{@source}->#{@destination}"
      end

      # Convert to data for RFC8345 format
      # @return [Hash]
      def to_data
        data = {
          'link-id' => @name,
          '_diff_state_' => @diff_state.to_data,
          'source' => @source.to_data(:source),
          'destination' => @destination.to_data(:destination)
        }
        add_supports_and_attr(data, 'supporting-link')
      end

      private

      # @param [Hash] data RFC8345 data (link element)
      # @param [String] key Term-point ref data key of link ('source' or 'destination')
      # @return [TpRef, nil] Term-point ref or nil if the tp not found
      def create_link_edge(data, key)
        data.key?(key) ? TpRef.new(data[key], @parent_path) : nil
      end

      # @param [Symbol] attr (:source or :destination, direction attribute key)
      # @param [Link] other Link to compare
      # @return [TpRef] Diff of term-point ref
      def diff_link_tp(attr, other)
        result = send(attr) == other.send(attr) ? :kept : :changed
        d_tp = TpRef.new(send(attr).to_data(attr), @parent_path)
        d_tp.diff_state = DiffState.new(forward: result, pair: other)
        d_tp
      end
    end
  end
end
