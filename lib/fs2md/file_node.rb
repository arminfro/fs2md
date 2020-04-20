# frozen_string_literal: true

class FileNode < Node
  def initialize(name, path, parent_node = nil)
    @file = File.new(File.join(path, name), 'r')
    name  = File.basename(@file).sub(File.extname(@file), '')
    super(path, name, parent_node)
  end

  def read
    FileNodeContentParser.new(File.read(@file).split("\n"), @path, name(:beautiful), depth, self).parse
  end

  def output_filename
    File.join(super, @name + (Node.config[:print_beamer] ? '_beamer' : ''))
  end
end
