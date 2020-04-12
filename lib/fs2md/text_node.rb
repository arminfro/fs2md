# frozen_string_literal: true

class TextNode < Node
  attr_reader :name # , :content
  def initialize(name, content, depth, path, parent)
    @name    = name
    @parent  = parent
    @content = TextNodeContentParser.new(content, path).parse
    @depth   = depth
    @childs  = []
  end

  def to_s(mode = nil)
    return super() if mode == :just_name

    if Node.config[:print_beamer]
      "# #{@name.gsub('#', '')}\n\n#{@content.split("\n").map { |c| sub_beginning_hash_char(c) }.join("\n")}\n"
    else
      "#{'#' * @depth}#{@name.include?('#') ? '' : ' '}#{@name}\n\n#{@content}\n"
    end
  end
  alias content to_s

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

TextNodeContentParser = Struct.new(:content, :path) do
  def parse
    content.split("\n").map do |line|
      line.split(/\s/).map do |word|
        word = MutatedVowel.new(word).parse_word
        if picture?(word)
          relative_path_img = string_between_markers(word, '(', ')')
          word              = word.sub(relative_path_img, File.join(Dir.pwd, path, relative_path_img))
        end
        word
      end.join(' ')
    end.join("\n")
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
