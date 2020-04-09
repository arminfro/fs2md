# frozen_string_literal: true

class DirNode < Node
  include Enumerable
  def initialize(name, path, parent_node = nil)
    super
    @file_nodes = []
    @dir_nodes  = []
    @childs     = { rec: nil, flat: nil }
  end

  def add_dir(dir)
    @dir_nodes.push(dir)
  end

  def add_file(file)
    @file_nodes.push(file)
  end

  def childs(recursive = true)
    ref            = recursive ? :rec : :flat
    @childs[ref] ||= begin
                       c = [*@dir_nodes, *@file_nodes]
                       if @dir_nodes.size.positive?
                         if recursive
                           @dir_nodes.each do |d|
                             c.push(*d.childs)
                           end
                         end
                       end
                       c.sort_by(&:name)
                     end
  end

  def each
    childs.each do |c|
      yield(c)
    end
  end

  def files(recursive = true)
    childs(recursive).select { |c| c.is_a?(FileNode) }.sort_by(&:name)
  end

  def dirs(recursive = true)
    childs(recursive).select { |c| c.is_a?(DirNode) }.sort_by(&:name)
  end

  def to_s
    super + [*@file_nodes, *@dir_nodes].sort_by(&:name).map(&:to_s).join
  end

  def print
    output_dir = 'output'
    # FileUtils.remove_dir(output_dir)
    FileUtils.mkdir(output_dir) unless File.exist?(output_dir)
    to_pdf(output_dir)
    # childs.each { |c| c.to_pdf(output_dir) }
  end

  def size
    childs.size
  end

  def content
    child_content = childs(false).map(&:content).join("\n")
    @parent_node.nil? ? child_content : "#{'#' * ($beamer ? 1 : depth)} #{beautify_name}\n\n#{child_content}"
  end

  def read_tree
    Dir.glob("#{@path}/*")
       .select do |f|
      ff = File.new(f)
      ff && (File.directory?(ff) || (File.file?(ff) && ff.path =~ /.*md\z/))
    end
       .each do |d|
      is_file  = File.file?(File.new(d))
      if is_file
        node_type       = FileNode
        node_collection = @file_nodes
      else
        node_type       = DirNode
        node_collection = @dir_nodes
      end
      path_ref = is_file ? d.split('/')[0..-2].join('/') : d
      node     = node_type.new(d.split('/').last, path_ref, self)
      node_collection.push(node)
      node.read_tree unless is_file
    end
  end
end
