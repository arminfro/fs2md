# frozen_string_literal: true

ContentParser = Struct.new(:content, :path) do
  def parse
    char_map = { ue: 'ü', ae: 'ä', oe: 'ö', Ue: 'Ü', Ae: 'Ä', Oe: 'Ö', ss: 'ß' }
    content.split("\n").map do |line|
      line.split(/\s/).map do |word|
        if Node.config[:mutated_vowel_transformation]
          word.scan(Regexp.new(char_map.keys.join('|'))) do |match|
            unless skip_word?(word)
              word = word.gsub(match.to_s, char_map[match.to_s.to_sym])
          end
          end
        end
        if is_picture?(word)
          file_name = string_between_markers(word, '(', ')')
          word      = word.sub(file_name, "#{path}/#{file_name}")
        end
        word
      end.join(' ')
    end.join("\n")
  end

  def skip_word?(word)
    is_excluded_word = exceptions.any? { |p| word.downcase.include?(p) }
    is_link          = word =~ /\[.*\]\(.*\)/
    is_correct_word  = Spellchecker.check(word, 'de_DE').first[:correct]

    is_link || is_excluded_word || is_correct_word
  end

  def is_picture?(word)
    return true if word =~ /!\[\].*/
  end

  def exceptions
    %w[vue heroes true class klassen assert value myvalue password]
  end

  def string_between_markers(word, marker1, marker2)
    word[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end
end

class TextNode < Node
  attr_reader :name, :content
  def initialize(name, content, depth, path, parent)
    @name    = name
    @parent  = parent
    @content = ContentParser.new(content, path).parse
    @depth   = depth
    # @childs  = []
  end

  def to_s(mode = nil)
    return super() if mode == :just_name

    if $beamer
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
