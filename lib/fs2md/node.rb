# frozen_string_literal: true

class Node
  attr_reader :parent, :name, :path
  attr_accessor :childs
  def initialize(path, parent = nil)
    @path   = path
    @parent = parent
    @childs = read
  end

  class << self
    attr_accessor :config

    def reroot_by_index_range(index_range, all_nodes)
      first_node = all_nodes[index_range.first]
      last_node  = all_nodes[index_range.last]
      node       = first_node.root? ? first_node : first_node.first_common_parent(last_node)

      node_indices_ignore = (all_nodes.first.index..(first_node.index - 1)).to_a +
                            ((last_node.index + 1)..all_nodes.last.index).to_a -
                            [first_node.index, last_node.index, node.index]

      if node_indices_ignore.size.positive?
        node.childs                                        = [first_node]
        node_indices_ignore.each { |i| all_nodes[i].childs = [] }
        node.root!
      end
      node
    end
  end

  @config = {
    type_scope: :text,
    print_beamer: false,
    mutated_vowel_transformation: true
  }

  def depth
    parents.size
  end

  def to_s(_mode = nil)
    "[#{index}]#{'   ' * depth} - #{@name} \n#{childs.select(&:type_filter).map(&:to_s).join}"
  end

  def childs(mode = :flat)
    case mode
    when :flat then @childs
    when :all then ([self] + @childs.map { |c| c.childs(:all) }).flatten
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
    binding.pry
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

    last_sibling = last_sibling.childs.last until last_sibling.is_a?(TextNode)
    last_sibling || @parent
  end

  def content
    @childs.map(&:content).join("\n")
  end

  def size
    childs(:all).size
  end

  def output_dir
    'output'
  end

  def output_filename
    File.join(output_dir, @path)
  end

  def print
    if content.empty?
      puts("no content for given node: #{@name}")
      return
    end

    filename = output_filename
    dirname  = File.dirname(filename)
    FileUtils.mkdir_p(dirname) unless File.exist?(dirname)

    File.open("#{filename}.md", 'w') { |f| f.write(content) }
    styles  = %w[pygments kate monochrome espresso haddock tango zenburn]
    command = "pandoc #{if Node.config[:print_beamer]
                          '-t beamer'
                        else
                          '--toc --toc-depth 6 -V toc-title=\'Inhaltsverzeichnis\''
    end} -V linkcolor:blue --highlight-style #{styles[5]} -s '#{filename}.md' -o '#{filename}.pdf'"
    system(command)
    puts "Printed #{filename}.pdf"
  end

  def beautify_name
    @name.sub(/\d{1,3}/, '').gsub('_', ' ').strip
  end
end
