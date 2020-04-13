# frozen_string_literal: true

class FileNode < Node
  def initialize(name, path, parent_node = nil)
    @file = File.new(File.join(path, name), 'r')
    name  = File.basename(@file).sub(File.extname(@file), '')
    super(path, name, parent_node)
  end

  def read
    FileNodeContentParser.new(File.read(@file).split("\n"), @path, name(:beautiful), depth).parse
  end

  def output_filename
    File.join(super, @name + (Node.config[:print_beamer] ? '_beamer' : ''))
  end

  FileNodeContentParser = Struct.new(:content, :path, :name, :depth) do
    def parse
      text_nodes = node_indices_to_content_arr(text_node_indices)
      if text_nodes.empty?
        [TextNode.new(name, content.join("\n"), depth, path, self)]
      elsif name == text_nodes.first.name
        text_nodes
      else
        text_nodes.unshift(TextNode.new(name, '', depth, path, self))
      end
    end

    def text_node_indices
      content.each_with_index.map do |line, index|
        last_ele                = index == content.size - 1
        is_headline             = line =~ /\A#/
        starts_without_headline = index.zero? && !is_headline

        index if is_headline || last_ele || starts_without_headline
      end.compact
    end

    def node_indices_to_content_arr(indices)
      indices[..-2].map do |index|
        starts_without_headline = index.zero? && content[index] !~ /\A#/
        if starts_without_headline
          headline   = name
          node_depth = depth
        else
          count      = content[index].count('#')
          node_depth = depth + count
          headline   = content[index].sub('#', '').strip
        end

        range        = (index + 1)..indices[indices.index(index) + 1]
        last         = range.last == content.size - 1
        text_content = content[(starts_without_headline ? range.first - 1 : range.first)..(last ? range.last : range.last - 1)].join("\n")
        TextNode.new(headline, text_content, node_depth, path, self)
      end
    end
  end
end
