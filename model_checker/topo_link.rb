module TopoChecker
  # Link for topology data
  class Link
    attr_reader :name, :path, :source, :destination, :supporting_links

    # Termination point reference
    class TpRef
      attr_reader :node_ref, :tp_ref

      def initialize(data, parent_path)
        @parent_path = parent_path
        @node_ref = data['source-node'] || data['dest-node']
        @tp_ref = data['source-tp'] || data['dest-tp']
      end

      def ==(other)
        @node_ref == other.node_ref && @tp_ref == other.tp_ref
      end

      def to_s
        "tp_ref:#{@node_ref}/#{tp_ref}"
      end

      def ref_path
        [@parent_path, @node_ref, @tp_ref].join('/')
      end
    end

    # Supporting link for topology link data
    class SupportingLink
      attr_reader :network_ref, :link_ref
      def initialize(data)
        @network_ref = data['network-ref']
        @link_ref = data['link-ref']
      end

      def to_s
        "link_ref:#{@network_ref}/#{@link_ref}"
      end
    end

    def initialize(data, parent_path)
      @name = data['link-id']
      @path = [parent_path, @name].join('/')
      @source = TpRef.new(data['source'], parent_path)
      @destination = TpRef.new(data['destination'], parent_path)

      @supporting_links = []
      return unless data.key?('supporting-link')
      @supporting_links = data['supporting-link'].map do |slink|
        SupportingLink.new(slink)
      end
    end

    def to_s
      "link:#{@source}->#{@destination}"
    end
  end
end
