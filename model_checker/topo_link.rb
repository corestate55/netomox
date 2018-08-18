require_relative 'topo_support_link'

module TopoChecker
  # Link for topology data
  class Link
    attr_reader :name, :path, :source, :destination, :supporting_links
    alias_method :supports, :supporting_links

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

    def -(other)
      deleted_slinks = @supporting_links - other.supports
      added_slinks = other.supports - @supporting_links
      kept_slinks = @supporting_links & other.supports
      puts '    - supporting links'
      puts "      - deleted sup-links: #{deleted_slinks.map(&:to_s)}"
      puts "      - added   sup-links: #{added_slinks.map(&:to_s)}"
      puts "      - kept    sup-links: #{kept_slinks.map(&:to_s)}"
      [:source, :destination].each do |d|
        puts "    - #{d}"
        result = self.send(d) == other.send(d) ? 'kept' : 'changed'
        puts "      - #{result}: #{other.send(d)}"
      end
    end

    def eql?(other)
      # for Links#-()
      # p "Link#eql? #{name} - #{other.name}"
      @name == other.name
    end

    def to_s
      "link:#{name}" #"#{@source}->#{@destination}"
    end
  end
end
