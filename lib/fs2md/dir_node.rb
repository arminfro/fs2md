# frozen_string_literal: true

class DirNode < Node
  include Enumerable
  def initialize(name, path, parent_node = nil)
    @name = name
    super(path, parent_node)
  end

  def read
    md_files = Dir.glob("#{@path}/*").select do |f|
      ff = File.new(f)
      ff && (File.directory?(ff) || (File.file?(ff) && ff.path =~ /.*md\z/))
    end

    md_files.map do |d|
      is_file   = File.file?(File.new(d))
      node_type = if is_file
                    FileNode
                  else
                    DirNode
                  end
      path_ref  = is_file ? d.split('/')[0..-2].join('/') : d
      node      = node_type.new(d.split('/').last, path_ref, self)
    end
  end

  def each(mode = :flat)
    childs(mode).each { |c| yield(c) }
  end

  def print
    output_dir = 'output'
    FileUtils.mkdir(output_dir) unless File.exist?(output_dir)
    to_pdf(output_dir)
  end

  def size
    childs(:all).size
  end

  def content
    child_content = childs(:flat).map(&:content).join("\n")
    @parent.nil? ? child_content : "#{'#' * ($beamer ? 1 : depth)} #{beautify_name}\n\n#{child_content}"
  end
end
