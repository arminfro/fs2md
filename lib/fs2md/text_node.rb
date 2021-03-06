# frozen_string_literal: true

class TextNode < Node
  attr_reader :depth
  def initialize(name, content, depth, path, parent)
    @name    = Node.mutated_vowel_transformation(name.sub('#', ''))
    @depth   = depth + calc_depth(name)
    @parent  = parent
    @content = TextNodeContentParser.new(content.split("\n"), path).parse
    @childs  = []
  end

  def content
    content_body.empty? ? '' : "#{headline}\n#{content_body}\n"
  end

  def calc_depth(name)
    scan_result = name.scan(/\A#./)
    if @name.empty? || scan_result.empty?
      0
    else
      scan_result.first.count('#')
    end
  end

  def content_body
    if Node.config[:print_beamer]
      @content.split("\n").map { |c| sub_beginning_hash_char(c) }.join("\n")
    else
      @content
    end
  end

  def headline
    if @name.empty?
      ''
    else
      Node.config[:print_beamer] ? "# #{@name} {.allowframebreaks}\n" : "#{'#' * depth} #{@name}\n"
    end
  end

  private

  def sub_beginning_hash_char(content)
    if content =~ /\A#+/
      m = content.match(/\A#+/)
      "##{m.post_match}"
    else
      content
    end
  end
end
