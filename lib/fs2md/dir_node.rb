# frozen_string_literal: true

class DirNode < Node
  include Enumerable
  def initialize(name, path, parent_node = nil)
    @name = name
    super(path, parent_node)
  end

  def read
    files = Dir.glob("#{@path}/*").select do |f|
      file             = File.new(f)
      is_directory     = File.directory?(file)
      is_markdown_file = File.file?(file) && file.path =~ /.*md\z/
      file && (is_directory || is_markdown_file)
    end

    files.map do |d|
      is_file   = File.file?(File.new(d))
      node_type = if is_file
                    FileNode
                  else
                    DirNode
                  end
      path_ref  = is_file ? d.split('/')[0..-2].join('/') : d
      node_type.new(d.split('/').last, path_ref, self)
    end.sort_by(&:name)
  end

  def each(mode = :flat)
    childs(mode).each { |c| yield(c) }
  end

  def content
    child_content = childs(:flat).map(&:content).join("\n")
    @parent.nil? ? child_content : "#{'#' * ($beamer ? 1 : depth)} #{beautify_name}\n\n#{child_content}"
  end
end
