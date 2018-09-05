require 'netomox/topology/link'

module Netomox
  module GraphDB
    # Link for graph data
    class GraphLink < Topology::Link
      def initialize(data, parent_path)
        super(data, parent_path)
      end

      def n4j_create
        # p "create relationship, Label:connected, id:#{@path},
        # src:#{@source.ref_path}, dst:#{@destination.ref_path}"
        {
          object_type: :relationship,
          rel_type: :connected,
          labels: [],
          property: {
            source: @source.ref_path,
            destination: @destination.ref_path
          }
        }
      end
    end
  end
end
