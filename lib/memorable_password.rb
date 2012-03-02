require 'memorable_password/sample'

# This class uses for generation memorable passwords
# You may instantiatie it with additional ban list:
#
#   memorable_password = MemorablePassword.new(['bad word'])
#
# Simple password which is two 4-char word joined by non-ambiguous digit may be generated using {MemorablePassword#generate_simple}:
#
#   MemorablePassword.new.generate_simple
#   # => "sons3pied"
class MemorablePassword
  MAX_WORD_LENGTH = 7
  DIGITS = (0..9).map(&:to_s).freeze
  NON_AMBIGUOUS_DIGITS = ((0..9).to_a - [2, 4]).map(&:to_s).freeze
  CHARACTERS = %w[! @ $ ? -].freeze

  DEFAULT_OPTIONS = {
    :mixed_case => false,
    :special_characters => false,
    :length => nil,
    :min_length => nil
  }

  attr_accessor :dictionary, :blacklist, :ban_list

  # Constructor.
  # +ban_list+:: additional words list should be added to blacklist
  def initialize(ban_list = [])
    @ban_list = ban_list
    @dictionary = nil
    @blacklist = nil
    initialize_dictionary
  end

  # Generates memorable password as a combination of two 4-letter dictionary words joined by a numeric character (but not 4 and 8).
  def generate_simple
    password = word(4)
    password << non_ambiguous_digit
    password << word(4)
    password
  end

  # Generates memorable password.
  # +opts+:: hash with options
  # [:mixed_case] +true+ or +false+ - use mixedCase (default: +false+)
  # [:special_characters] +true+ or +false+ - use special characters like ! @ $? - (default: +false+)
  # [:length] Fixnum - generate passoword with specific length
  # [:min_length] Fixnum - generate passoword with length grather or equal of specified
  # Options +:length+ and +:min_length+ are incompatible.
  def generate(opts={})
    opts = DEFAULT_OPTIONS.merge(opts)

    raise "You cannot specify :length and :min_length at the same time" if opts[:length] && opts[:min_length]  # Nonsense!

    if opts[:length]
      password = [(opts[:length] >= 8 ? long_word : word), (opts[:special_characters] ? character : digit)]
      password << word(opts[:length] - password.compact.join.length)

      if (count = opts[:length] - password.compact.join.length) > 0
        if count == 1
          password << digit
        else
          password << word(count)
        end
      end

    else
      if opts[:special_characters]
        password = [word, character, word, digit]
      else
        password = [word, digit, long_word]
      end
    end

    if opts[:mixed_case]
      password.compact.reject{|x| x.length == 1}.sample.capitalize!
    end

    # If a minimum length is required and this password is too short
    if opts[:min_length] && password.compact.join.length < opts[:min_length]
      if (count = opts[:min_length] - password.compact.join.length) == 1
        password << digit
      else
        password << word(count)
      end
    end

    # If it is too long, just cut it down to size. This should not happen often unless the :length option is present and is very small.
    if opts[:length] && password.compact.join.length > opts[:length]
      result = password.compact.join.slice(0, opts[:length])

      # If there is no digit then it is probably a short password that by chance is just a dictionary word. Override that because that is bad.
      if result =~ /^[a-z]+$/
        password = [(opts[:mixed_case] ? word(opts[:length] - 1).capitalize : word(opts[:length] - 1)), (opts[:special_characters] ? character : digit)]
        result = password.compact.join
      end

      result
    else
      password.compact.join
    end
  end

  private

  # Returns random character
  def character
    CHARACTERS.sample
  end

  # Returns random digit
  def digit
    DIGITS.sample
  end

  # Returns random non-ambiguous digit (0..9 without 2 and 4)
  def non_ambiguous_digit
    NON_AMBIGUOUS_DIGITS.sample
  end

  # Returns random word. If +length+ given, find word with this length.
  def word(length=nil)
    length = self.dictionary.keys.sample if !length || length > self.dictionary.keys.max
    self.dictionary[length].sample if self.dictionary.has_key?(length)
  end

  # Returns random word from most long ones
  def long_word
    keys = self.dictionary.keys.sort
    self.dictionary[keys.partition{|v| v >= keys[keys.size/2] }.first.sample].sample  # Magic! It actually just randomly picks from the larger words..
  end

  # Adds +word+ to dictionary if it not in blacklist
  def add_word(word)
    word = word.strip.downcase
    length = word.length

    if length <= MAX_WORD_LENGTH && length > 1 && word =~ /^[a-z]+$/ && !self.blacklist.include?(word)
      self.dictionary[length] = [] unless self.dictionary[length]
      self.dictionary[length] << word
    end
  end

  # Adds +word+ to blacklist
  def add_to_blacklist(word)
    word = word.strip.downcase
    self.blacklist << word if word =~ /^[a-z]+$/
  end

  # Initializes dictionary hash from system dicitionary, memorable_password names.
  # Exclude words from blacklist.txt and password_ban_words table,
  def initialize_dictionary
    unless self.dictionary
      self.dictionary = {}
      self.blacklist = []

      # Load blacklist from text file
      File.foreach(File.join(File.dirname(__FILE__), 'memorable_password', 'blacklist.txt')){ |word| add_to_blacklist(word) }

      ban_list.each{ |word| add_to_blacklist(word) }

      # Load system dictionary words
      File.foreach("/usr/share/dict/words"){ |word| add_word(word) }

      # Load list of proper names
      File.foreach(File.join(File.dirname(__FILE__), 'memorable_password', 'names.txt')){ |word| add_word(word) }
    end

    self.dictionary
  end

  # Re-initializes dicitionary
  def reload_dictionary
    self.dictionary = nil
    initialize_dictionary
  end
end
