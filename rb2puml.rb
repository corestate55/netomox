require 'optparse'

# info record of klass
class KlassRecords
  attr_accessor :pub_methods, :priv_methods, :prot_methods,
                :vars, :uses, :parents
  def initialize
    @pub_methods = []
    @priv_methods = []
    @prot_methods = []
    @parents = []
    @vars = []
    @uses = []
  end
end

# rubocop:disable Metrics/ClassLength
# ruby to PlantUML
class RB2Puml
  attr_reader :kls_table
  def initialize(dir)
    target_dir = dir
    target_pattern = '*.rb'
    @target_files = Dir.glob("#{target_dir}/#{target_pattern}")
    @kls_table = {}
  end

  def to_puml
    ['@startuml', to_puml_class, '@enduml']
  end

  def parse_line
    all_lines do |line|
      parse_single_def(line)
      push_use(line)
      push_var(line)
    end
  end

  private

  def push(key, value)
    # puts "# check#push #{@kls_name}, #{key}, #{value}"
    @kls_table[@kls_name] = KlassRecords.new unless @kls_table.key?(@kls_name)
    @kls_table[@kls_name].send(key).push(value)
  end

  def all_lines
    @target_files.each do |file_name|
      File.open(file_name, 'r') do |file|
        @file_name = File.basename(file_name)
        @method_mode = :pub_methods
        # puts "# File: #{@file_name}, change mode to public"
        file.each_line do |line|
          yield line
        end
      end
    end
  end

  def to_puml_class
    list = @kls_table.keys.map do |kls|
      [
        "class #{kls} {", to_puml_methods(kls), to_puml_vars(kls), '}',
        to_puml_parents(kls), to_puml_uses(kls)
      ]
    end
    list.flatten
  end

  def method_head(mode)
    case mode
    when :pub_methods then '+'
    when :priv_methods then '-'
    when :prot_methods then '#'
    end
  end

  def to_puml_methods(kls)
    list = %i[pub_methods prot_methods priv_methods].map do |mode|
      @kls_table[kls].send(mode).map do |method|
        head = method_head(mode)
        "  #{head}#{method}()"
      end
    end
    list.flatten
  end

  def to_puml_vars(kls)
    @kls_table[kls].vars.sort.uniq.map do |var|
      "  #{var}"
    end
  end

  def to_puml_parents(kls)
    @kls_table[kls].parents.sort.uniq.map do |parent|
      "#{kls} --|> #{parent}"
    end
  end

  def to_puml_uses(kls)
    @kls_table[kls].uses.sort.uniq.map do |use|
      "#{kls} --- #{use}"
    end
  end

  def parse_class_name(kls, parent_kls = '')
    @kls_name = kls
    push_parent(parent_kls) if parent_kls
  end

  # rubocop:disable Metrics/MethodLength
  def parse_single_def(line)
    case line
    when /^\s*#.*/
      nil # comment line
    when /^\s*class ([\w:]+) < ([\w:]+)/, /^\s*class ([\w:]+)/
      parse_class_name(Regexp.last_match(1), Regexp.last_match(2))
    when /^\s*def ([\w\?]+)/
      push_method(Regexp.last_match(1))
    when /^\s*protected\s*$/
      @method_mode = :prot_methods
    when /^\s*private\s*$/
      @method_mode = :priv_methods
    end
  end
  # rubocop:enable Metrics/MethodLength

  def push_parent(parent_name)
    push(:parents, parent_name)
  end

  def push_method(method_name)
    push(@method_mode, method_name)
  end

  def push_var(line)
    return unless line =~ /@(\w+)/
    push(:vars, Regexp.last_match(1))
  end

  def use_match(line)
    case line
    when /([\w:]+)\.new/, /klass: ([\w:]+)/,
         /setup_supports\(\w+, ['\-\w]+, ([\w:]+)\)/
      Regexp.last_match(1)
    else
      false
    end
  end

  def push_use(line)
    use_kls_name = use_match(line)
    push(:uses, use_kls_name) if use_kls_name
  end
end
# rubocop:enable Metrics/ClassLength

opt = OptionParser.new
option = {}
opt.on('-d', '--dir=DIR', 'ruby source directory') do |v|
  option[:dir] = v
end
opt.parse!(ARGV)
if option[:dir]
  rb2puml = RB2Puml.new(option[:dir])
  rb2puml.parse_line
  puts rb2puml.to_puml
else
  warn opt.help
  exit 1
end
