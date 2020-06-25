# frozen_string_literal: true

class TextNode < Node
  attr_reader :depth
  def initialize(name, content, depth, path, parent)
    @name    = Node.mutated_vowel_transformation(name.gsub('#', ''))
    @depth   = depth + (@name.empty? ? 0 : name.count('#'))
    @parent  = parent
    @content = TextNodeContentParser.new(content.split("\n"), path).parse
    @childs  = []
  end

  def content
    content_body.empty? ? '' : "#{headline}\n#{content_body}\n"
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
      Node.config[:print_beamer] ? "# #{@name}\n" : "#{'#' * depth} #{@name}\n"
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
