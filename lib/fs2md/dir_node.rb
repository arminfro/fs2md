# frozen_string_literal: true

class DirNode < Node
  include Enumerable
  def initialize(path, parent_node = nil)
    super(path, parent_node)
  end

  def read
    map_files(read_files(Dir.glob("#{@path}/*")))
  end

  def read_files(files)
    files.select do |f|
      file             = File.new(f)
      is_directory     = File.directory?(file)
      is_markdown_file = File.file?(file) && file.path =~ /.*md\z/
      file && (is_directory || is_markdown_file)
    end
  end

  def map_files(files)
    files.map do |d|
      is_file   = File.file?(File.new(d))
      node_type = if is_file
                    FileNode
                  else
                    DirNode
                  end
      node_type.new(d, self)
    end.sort_by(&:name)
  end

  def each(mode = :flat)
    childs(mode).each { |c| yield(c) }
  end

  def content
    child_content = super
    if @parent.nil?
      child_content
    else
      headline = "#{'#' * (Node.config[:print_beamer] ? 1 : depth)} #{name(:beautiful)}"
      "#{headline}\n\n#{child_content}"
    end
  end
end
