require_relative 'topo_const'
require_relative 'topo_support_link'
require_relative 'topo_link_attr'
require_relative 'topo_diff'
require_relative 'topo_object_base'

module TopoChecker
  # Link for topology data
  class Link < TopoObjectBase
    attr_reader :source, :destination
    include TopoDiff

    def initialize(data, parent_path)
      super(data['link-id'], parent_path)
      @source = TpRef.new(data['source'], parent_path)
      @destination = TpRef.new(data['destination'], parent_path)
      setup_supports(data, 'supporting-link', SupportingLink)
      setup_attribute(data,[
        { key: "#{NS_L2NW}:l2-link-attributes", klass: L2LinkAttribute },
        { key: "#{NS_L3NW}:l3-link-attributes", klass: L3LinkAttribute}
      ])
    end

    def -(other)
      diff_link_tp(other)
      diff_supports(other)
      diff_attribute(other)
    end

    def eql?(other)
      # for Links#-()
      # p "Link#eql? #{name} - #{other.name}"
      @name == other.name
    end

    def to_s
      "link:#{name}" # "#{@source}->#{@destination}"
    end

    private

    def diff_link_tp(other)
      %i[source destination].each do |d|
        puts "    - #{d}"
        result = send(d) == other.send(d) ? 'kept' : 'changed'
        puts "      - #{result}: #{other.send(d)}"
      end
    end
  end
end
