require 'netomox/const'
require 'netomox/topology/link_tpref'
require 'netomox/topology/link_attr'
require 'netomox/topology/base'

module Netomox
  module Topology
    # Link for topology data
    class Link < TopoObjectBase
      attr_accessor :source, :destination

      ATTR_KEY_KLASS_LIST = [
        { key: "#{NS_L2NW}:l2-link-attributes", klass: L2LinkAttribute },
        { key: "#{NS_L3NW}:l3-link-attributes", klass: L3LinkAttribute }
      ].freeze

      def initialize(data, parent_path)
        super(data['link-id'], parent_path)
        setup_source(data)
        setup_destination(data)
        setup_supports(data, 'supporting-link', SupportingLink)
        setup_attribute(data, ATTR_KEY_KLASS_LIST)
      end

      def diff(other)
        # forward check
        d_link = Link.new({ 'link-id' => @name }, @parent_path)
        d_link.source = diff_link_tp(:source, 'source', other)
        d_link.destination = diff_link_tp(:destination, 'dest', other)
        d_link.supports = diff_supports(other)
        d_link.attribute = diff_attribute(other)
        d_link.diff_state = select_diff_state(other)
        # backward check
        d_link.diff_backward_check(%i[source destination supports attribute])
        # return
        d_link
      end

      def fill_diff_state
        fill_diff_state_of(%i[source destination supports attribute])
      end

      def to_s
        "link:#{name}" # "#{@source}->#{@destination}"
      end

      def to_data
        data = {
          'link-id' => @name,
          '_diff_state_' => @diff_state.to_data,
          'source' => @source.to_data('source'),
          'destination' => @destination.to_data('dest')
        }
        add_supports_and_attr(data, 'supporting-link')
      end

      private

      def setup_source(data)
        @source = nil
        return unless data.key?('source')

        @source = TpRef.new(data['source'], @parent_path)
      end

      def setup_destination(data)
        @destination = nil
        return unless data.key?('destination')

        @destination = TpRef.new(data['destination'], @parent_path)
      end

      def diff_link_tp(attr, to_data_key, other)
        result = send(attr) == other.send(attr) ? :kept : :changed
        d_tp = TpRef.new(send(attr).to_data(to_data_key), @parent_path)
        d_tp.diff_state = DiffState.new(forward: result, pair: other)
        d_tp
      end
    end
  end
end
