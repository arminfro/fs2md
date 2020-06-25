# frozen_string_literal: true

TextNodeContentParser = Struct.new(:splitted_content, :path) do
  def parse
    splitted_content.map do |line|
      if line =~ /\s{6,}\*\s/
        puts "Warning: found too much indentation at line #{line.strip}. It'll get autocorrected"
        line = line[(line.length - 6)..]
      end
      transform_line?(line) ? line : parse_words(line.split(/\s/))
    end.join("\n")
  end

  def parse_words(words)
    is_inline_code = false
    words.map do |word|
      is_inline_code      = true if word =~ /\A`.*/
      skip_vowel_mutation = word =~ /\A`.*`\z/ || is_inline_code
      word                = skip_vowel_mutation ? word : MutatedVowel.new(word).parse_word
      is_inline_code      = false if word =~ /.*`\z/
      picture?(word) ? picture_word(word) : word
    end.join(' ')
  end

  def transform_line?(line)
    index            = splitted_content.index(line)
    is_in_code_block = false
    splitted_content[0..index].each do |e_line|
      is_in_code_block = !is_in_code_block if e_line =~ /\A```/
    end
    is_in_code_block
  end

  def picture_word(word)
    relative_path_img = string_between_markers(word, '(', ')')
    word.sub(
      relative_path_img,
      File.join(Pathname.new(path).split[0], relative_path_img)
    )
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