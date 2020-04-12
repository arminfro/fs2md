# frozen_string_literal: true

MutatedVowel = Struct.new(:word) do
  CHAR_MAP = {
    ue: 'ü', ae: 'ä', oe: 'ö',
    Ue: 'Ü', Ae: 'Ä', Oe: 'Ö',
    ss: 'ß'
  }.freeze

  EXCEPTIONS = %w[
    vue heroes true class klassen assert value myvalue password
  ].freeze

  def parse_word
    return word unless Node.config[:mutated_vowel_transformation]

    word.scan(Regexp.new(CHAR_MAP.keys.join('|'))) do |match|
      return skip_word? ? word : word.gsub(match.to_s, CHAR_MAP[match.to_s.to_sym])
    end
  end

  def skip_word?
    is_excluded_word = EXCEPTIONS.any? { |p| word.downcase.include?(p) }
    is_link          = word =~ /\[.*\]\(.*\)/
    is_correct_word  = Spellchecker.check(word, 'de_DE').first[:correct]

    is_link || is_excluded_word || is_correct_word
  end
end