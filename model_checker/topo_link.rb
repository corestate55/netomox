require_relative 'topo_const'
require_relative 'topo_support_link'
require_relative 'topo_link_attr'

module TopoChecker
  # Link for topology data
  class Link
    attr_reader :name, :path, :source, :destination,
                :supporting_links, :attribute
    alias supports supporting_links

    def initialize(data, parent_path)
      @name = data['link-id']
      @path = [parent_path, @name].join('/')
      @source = TpRef.new(data['source'], parent_path)
      @destination = TpRef.new(data['destination'], parent_path)
      setup_supports(data)
      setup_attribute(data)
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

    def diff_attribute(other)
      puts '    - link attribute'
      result = if @attribute == other.attribute
                 :kept
               elsif @attribute.empty?
                 :added
               elsif other.attribute.empty?
                 :deleted
               else
                 :changed
               end
      puts "      - #{result}: #{@attribute} => #{other.attribute}"
    end

    def diff_link_tp(other)
      %i[source destination].each do |d|
        puts "    - #{d}"
        result = send(d) == other.send(d) ? 'kept' : 'changed'
        puts "      - #{result}: #{other.send(d)}"
      end
    end

    def diff_supports(other)
      deleted_slinks = @supporting_links - other.supports
      added_slinks = other.supports - @supporting_links
      kept_slinks = @supporting_links & other.supports
      puts '    - supporting links'
      puts "      - deleted sup-links: #{deleted_slinks.map(&:to_s)}"
      puts "      - added   sup-links: #{added_slinks.map(&:to_s)}"
      puts "      - kept    sup-links: #{kept_slinks.map(&:to_s)}"
    end

    def setup_attribute(data)
      l2link_attr_key = "#{NS_L2NW}:l2-link-attributes"
      l3link_attr_key = "#{NS_L3NW}:l3-link-attributes"
      # NOTICE: WITHOUT network type check
      @attribute = if data.key?(l2link_attr_key)
                     L2LinkAttribute.new(data[l2link_attr_key])
                   elsif data.key?(l3link_attr_key)
                     L3LinkAttribute.new(data[l3link_attr_key])
                   else
                     {}
                   end
    end

    def setup_supports(data)
      @supporting_links = []
      return unless data.key?('supporting-link')
      @supporting_links = data['supporting-link'].map do |slink|
        SupportingLink.new(slink)
      end
    end
  end
end
