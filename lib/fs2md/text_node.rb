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

  TextNodeContentParser = Struct.new(:splitted_content, :path) do
    def parse
      splitted_content.map do |line|
        if line =~ /\s{6,}\*\s/
          puts "Warning: found too much indentation at line #{line.strip}. It'll get autocorrected"
          line = line[(line.length - 6)..]
        end
        if transform_line?(line)
          line
        else
          words          = line.split(/\s/)
          is_inline_code = false
          words.map do |word|
            is_inline_code      = true if word =~ /\A`.*/
            skip_vowel_mutation = word =~ /\A`.*`\z/ || is_inline_code
            word                = skip_vowel_mutation ? word : MutatedVowel.new(word).parse_word
            is_inline_code      = false if word =~ /.*`\z/
            if picture?(word)
              relative_path_img = string_between_markers(word, '(', ')')
              word              = word.sub(
                relative_path_img,
                File.join(Dir.pwd, path, relative_path_img)
              )
            end
            word
          end.join(' ')
        end
      end.join("\n")
    end

    def transform_line?(line)
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
