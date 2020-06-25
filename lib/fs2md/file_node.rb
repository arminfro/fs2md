# frozen_string_literal: true

class FileNode < Node
  def initialize(path, parent_node = nil)
    @file = File.new(path, 'r')
    super(path, parent_node)
  end

  def read
    FileNodeContentParser.new(
      File.read(@file).split("\n"),
      @path, name(:beautiful), depth, self
    ).parse
  end
end
