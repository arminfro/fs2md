# frozen_string_literal: true

class FileNode < Node
  def initialize(name, path, parent_node = nil)
    @file = File.new(File.join(path, name), 'r')
    name  = File.basename(@file).sub(File.extname(@file), '')
    super(path, name, parent_node)
  end

  def read
    f_content     = File.read(@file).split("\n")
    io_with_index = with_index(strip_array(f_content))
    io            = io_with_index.map { |a| a[0] }

    node_indices = io_with_index.map do |l_i|
      l                       = l_i[0]
      i                       = l_i[1]
      last_ele                = i == io.size - 1
      is_headline             = l =~ /\A#/
      starts_without_headline = i == 0 && !is_headline

      i if is_headline || last_ele || starts_without_headline
    end.compact

    tt = node_indices[..-2].map do |i|
      starts_without_headline = i.zero? && io[i] !~ /\A#/
      if starts_without_headline
        headline   = name(:beautiful)
        node_depth = depth
      else
        count      = io[i].count('#')
        node_depth = depth + count
        headline   = io[i].sub('#', '').strip
      end
      range                   = (i + 1)..node_indices[node_indices.index(i) + 1]
      last                    = range.last == io.size - 1
      content                 = strip_array(io[(starts_without_headline ? range.first - 1 : range.first)..(last ? range.last : range.last - 1)]).join("\n")
      TextNode.new(headline, content, node_depth, path, self)
    end

    if tt.empty?
      [TextNode.new(name(:beautiful), io.join("\n"), depth, path, self)]
    elsif name(:beautiful) == tt.first.name
      tt
    else
      tt.unshift(TextNode.new(name(:beautiful), '', depth, path, self))
    end
    # todo, sort_by(&:name)
  end

  def output_filename
    File.join(super, @name + (Node.config[:print_beamer] ? '_beamer' : ''))
  end

  def with_index(io)
    side_effect_arr = []
    io.each_with_index { |l, i| side_effect_arr.push([l, i]) }
    side_effect_arr
  end

  # strip array of empty pre and post strings
  def strip_array(arr)
    first_line_index = nil
    last_line_index  = nil
    arr.each_with_index do |el, i|
      first_line_index = i if !el.empty? && first_line_index.nil?
      last_line_index  = i if (arr[i + 1].nil? || arr.size - 1 == i) && !el.empty?
    end
    arr[first_line_index..last_line_index]
  end
end
