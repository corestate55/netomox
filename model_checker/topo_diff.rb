module TopoChecker
  module TopoDiff
    def diff_list(attr, other)
      deleted_list = send(attr) - other.send(attr)
      added_list = other.send(attr) - send(attr)
      kept_list = send(attr) & other.send(attr)
      {
        deleted: deleted_list,
        added: added_list,
        kept: kept_list
      }
    end

    def print_diff_list(attr, diff_table)
      puts "## #{attr} of #{self.class.name}"
      puts "- deleted #{attr}: #{diff_table[:deleted].map(&:to_s)}"
      puts "- added   #{attr}: #{diff_table[:added].map(&:to_s)}"
      puts "- kept    #{attr}: #{diff_table[:kept].map(&:to_s)}"
    end

    def diff_kept(attr, diff_table, other)
      diff_table[:kept].each do |k|
        lhs = send(attr).find { |n| n.eql?(k) }
        rhs = other.send(attr).find { |n| n.eql?(k) }
        lhs - rhs
      end
    end

    def diff_supports(other)
      diff_table = diff_list(:supports, other)
      print_diff_list(:supports, diff_table)
    end

    def diff_attribute(other)
      puts "### attribute of #{self.class.name}"
      result = if @attribute == other.attribute
                 :kept
               elsif @attribute.empty?
                 :added
               elsif other.attribute.empty?
                 :deleted
               else
                 :changed
               end
      puts "  - #{result}: #{@attribute} => #{other.attribute}"
    end
  end
end
