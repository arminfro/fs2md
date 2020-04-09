# frozen_string_literal: true

ContentParser = Struct.new(:content, :path) do
  def parse
    char_map = { ue: 'ü', ae: 'ä', oe: 'ö', Ue: 'Ü', Ae: 'Ä', Oe: 'Ö' }
    content.split("\n").map do |line|
      # binding.pry if line.include?('Buy-Sell')
      line.split(/\s/).map do |word|
        word.match(/ue|ae|oe|Oe|Ae|Oe/) do |match|
          unless skip_word?(word)
            word = word.gsub(match.to_s, char_map[match.to_s.to_sym])
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
    is_excluded_word = parser_exceptions.any? { |p| word.downcase.include?(p) }
    is_link          = word =~ /\[.*\]\(.*\)/

    is_link || is_excluded_word
  end

  def is_picture?(word)
    return true if word =~ /!\[\].*/
  end

  def parser_exceptions
    %w[vue heroes aktuellen aktuell neuer true zuerst neue Neues Schauen]
  end

  def string_between_markers(word, marker1, marker2)
    word[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end
end

class TextNode < Node
  attr_reader :headline, :content
  def initialize(headline, content, depth, path)
    @headline = headline
    @content  = ContentParser.new(content, path).parse
    @depth    = depth
  end

  def to_s
    if $beamer
      "# #{@headline.gsub('#', '')}\n\n#{@content.split("\n").map { |c| sub_beginning_hash_char(c) }.join("\n")}\n"
    else
      "#{'#' * @depth}#{@headline.include?('#') ? '' : ' '}#{@headline}\n\n#{@content}\n"
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
