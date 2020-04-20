# frozen_string_literal: true

class TextNode < Node
  attr_reader :depth
  def initialize(name, content, depth, path, parent)
    @name    = Node.mutated_vowel_transformation(name.gsub('#', ''))
    @depth   = depth + (@name.empty? ? 0 : name.count('#'))
    @parent  = parent
    @content = TextNodeContentParser.new(content, path).parse
    @childs  = []
  end

  def content
    content_body.empty? ? '' : "#{headline}\n#{content_body}\n"
  end

  def content_body
    if Node.config[:print_beamer]
      @content.split("\n").map(&:reduce_hash_chars).join("\n")
    else
      @content
    end
  end

  def headline
    if @name.empty?
      ''
    else
      Node.config[:print_beamer] ? "# #{@name}\n" : "#{'#' * depth} #{@name}"
    end
  end

  private

  def reduce_hash_chars
    if @content =~ /\A#+/
      m = @content.match(/\A#+/)
      "##{m.post_match}"
    else
      @content
    end
  end

  TextNodeContentParser = Struct.new(:content, :path) do
    def parse
      content.split("\n").map do |line|
        if transform_line?(line)
          line
        else
          line.split(/\s/).map do |word|
            word = MutatedVowel.new(word).parse_word
            if picture?(word)
              relative_path_img = string_between_markers(word, '(', ')')
              word              = word.sub(relative_path_img, File.join(Dir.pwd, path, relative_path_img))
            end
            word
          end.join(' ')
        end
      end.join("\n")
    end

    def transform_line?(line)
      splitted_content = content.split("\n")
      index            = splitted_content.index(line)
      is_in_code_block = false
      splitted_content[0..index].each do |e_line|
        is_in_code_block = !is_in_code_block if e_line =~ /\A```/
      end
      is_in_code_block
    end

    # @todo, works only if there is no 'alt text' in image reference
    #        (otherwise the line to word splitter does wrong)
    def picture?(word)
      true if word =~ /!\[\].*/
    end

    def string_between_markers(word, marker1, marker2)
      word[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
    end
  end
end
