# frozen_string_literal: true

FileNodeContentParser = Struct.new(:content, :path, :name, :depth, :file_node) do
  def parse
    text_nodes = node_indices_to_text_node_arr(text_node_indices)
    if text_nodes.empty?
      [TextNode.new(name, content.join("\n"), depth, path, file_node)]
    elsif name == text_nodes.first.name
      text_nodes
    else
      text_nodes.unshift(TextNode.new(name, '', depth, path, file_node))
    end
  end

  private

  def text_node_indices
    content.each_with_index.map do |line, index|
      last_ele                = index == content.size - 1
      is_headline             = line =~ /\A#/
      starts_without_headline = index.zero? && !is_headline
      if last_ele && is_headline # edge case, empty headline without body
        index.positive? ? index - 1 : 0
      elsif is_headline || last_ele || starts_without_headline
        index
      end
    end.compact
  end

  def node_indices_to_text_node_arr(indices)
    indices[..-2].map do |index|
      t_h_d = text_head_depth_by_index(index, indices)
      TextNode.new(t_h_d[:headline], t_h_d[:content], t_h_d[:depth], path, file_node)
    end
  end

  def text_head_depth_by_index(index, indices)
    starts_without_headline = index.zero? && content[index] !~ /\A#/
    headline, depth         = headline_and_depth_by_index(index, starts_without_headline)
    content                 = content_by_index(index, starts_without_headline, indices)
    { content: content, headline: headline, depth: depth }
  end

  def headline_and_depth_by_index(index, starts_without_headline)
    if starts_without_headline
      headline = name
      l_depth  = depth
    else
      headline = content[index].sub('#', '').strip
      l_depth  = depth + 1
    end
    [headline, l_depth]
  end

  def content_by_index(index, starts_without_headline, indices)
    range                   = (index + 1)..indices[indices.index(index) + 1]
    last                    = range.last == content.size - 1
    c_begin                 = starts_without_headline ? range.first - 1 : range.first
    c_end                   = last ? range.last : range.last - 1
    content[c_begin..c_end].join("\n")
  end
end
