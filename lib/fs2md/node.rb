# frozen_string_literal: true

class Node
  attr_reader :parent, :path
  attr_writer :childs
  def initialize(path, name, parent = nil)
    @path   = path
    @name   = Node.mutated_vowel_transformation(name)
    @parent = parent
    @childs = read || []

    Node.childs_to_remove.push(self) unless childs(:all).any? { |c| c.is_a?(TextNode) }
    Node.childs_to_remove.map(&:remove_self_from_tree) if root?
  end

  class << self
    attr_accessor :config
    attr_accessor :childs_to_remove

    def mutated_vowel_transformation(string)
      string.split(' ').map { |n| MutatedVowel.new(n).parse_word }.join(' ')
    end

    def reroot_by_index_range(index_range, all_nodes)
      first_node = all_nodes[index_range.first]
      last_node  = all_nodes[index_range.last]
      node       = first_node.root? ? first_node : first_node.first_common_parent(last_node)

      node_indices_ignore = (all_nodes.first.index..(first_node.index - 1)).to_a +
                            ((last_node.index + 1)..all_nodes.last.index).to_a -
                            [first_node.index, last_node.index, node.index]

      if node_indices_ignore.size.positive?
        node_indices_ignore.each { |i| all_nodes[i].remove_self_from_tree }
        node.root!
      end
      node
    end
  end

  @childs_to_remove = []

  @config = {
    type_scope: :text,
    print_beamer: false,
    mutated_vowel_transformation: true,
    pandoc: {}
  }

  def depth
    parents.size
  end

  def to_s
    "[#{index}][#{self.class.to_s[0]}]#{'   ' * depth} - #{name(:beautiful)}\n"\
    "#{childs.select(&:type_filter).map(&:to_s).join}"
  end

  def content
    @childs.map(&:content).join("\n")
  end

  def childs(mode = :flat)
    case mode
    when :flat then @childs
    when :all_with_self then [self] + childs(:all)
    when :all then (@childs.map { |c| c.childs(:all_with_self) }).flatten
    end
  end

  def first_common_parent(other_node)
    return self unless parents

    (parents & other_node.parents).max_by(&:index)
  end

  def root!
    @parent = nil
  end

  def root?
    @parent.nil?
  end

  def type_filter
    case Node.config[:type_scope]
    when :dir; then is_a?(DirNode)
    when :file; then is_a?(DirNode) || is_a?(FileNode)
    when :text then true
    end
  end

  def parents
    @parents ||= begin
                 p       = @parent
                 parents = []
                 until p.nil?
                   parents.push(p)
                   p = p.parent
                 end
                 parents
               end
  end

  def siblings(mode = :all)
    return [] unless @parent || is_a?(TextNode)

    parent_childs = @parent.childs
    case mode
    when :all
      parent_childs
    when :before_self
      index_self = parent_childs.index(self)
      return [] if index_self < 1

      parent_childs[0..(index_self - 1)]
    end
  end

  def index
    return 0 if root?

    preceding_node.index + 1
  end

  def preceding_node
    last_sibling = siblings(:before_self).last

    return @parent if last_sibling.nil?

    last_sibling = last_sibling.childs.last until last_sibling.is_a?(TextNode) || last_sibling.childs.empty?
    last_sibling || @parent
  end

  def size
    childs(:all_with_self).size
  end

  def remove_self_from_tree
    @parent.childs = @parent.childs - [self]
  end

  def output_dir
    'output'
  end

  def output_filename
    File.join(output_dir, @path)
  end

  def generate_md
    if content.empty?
      puts("no content for given node: #{@name}")
      return
    end

    filename = output_filename
    dirname  = File.dirname(filename)
    FileUtils.mkdir_p(dirname) unless File.exist?(dirname)

    File.open("#{filename}.md", 'w') { |f| f.write(content) }
    shall_print_pandoc = Node.config[:pandoc].keys.size.positive?
    if shall_print_pandoc
      Node.config[:pandoc]['format'].split(',').each { |format| call_pandoc(filename, format.strip) }
    end

    puts "Printed #{filename}.md #{'and corresponding pandoc file' if shall_print_pandoc}"
  end

  def call_pandoc(filename, format)
    opts   = Node.config[:pandoc]['options']
    beamer = '-t beamer' if Node.config[:print_beamer]

    system("pandoc #{beamer} #{opts} -s '#{filename}.md' -o '#{filename}.#{format}'")
  end

  def name(mode = nil)
    case mode
    when :beautiful; then @name.sub(/\d{1,3}/, '').gsub('_', ' ').strip
    else @name
    end
  end
end
