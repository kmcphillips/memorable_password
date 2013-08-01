require 'memorable_password/sample'

# This class is used for generating memorable passwords.  It generates the password
# from a list of words, proper names, digits and characters.
#
# If no options are passed in, the dictionary is built from '/usr/share/dict/words'.
#
# Options are:
# * <tt>ban_list</tt> -  an array of words that should added to the blacklist
# * <tt>dictionary_paths</tt> - an array of paths to files that contain dictionary words
# * <tt>blacklist_paths</tt> - an array of paths to files that contain blacklisted words
#
# Option examples:
#   MemorablePassword.new(:ban_list => ['bad word'])
#   MemorablePassword.new(:dictionary_paths => ['path_to_dictionary/dict.txt'])
#   MemorablePassword.new(:blacklist_paths => ['path_to_blacklist/blacklist.txt'])
#
# == Generate password
# Generate a random password by calling #generate.
# See #generate for configuration details.
#
#   MemorablePassword.new.generate
#   # => "fig7joeann"
#
# == Generate simple password
# Generate a simple 9-character password by calling #generate_simple.
#
#   MemorablePassword.new.generate_simple
#   # => "sons3pied"
#
class MemorablePassword
  MAX_WORD_LENGTH = 7
  DIGITS = %w[0 1 2 3 4 5 6 7 8 9].freeze
  NON_WORD_DIGITS = (DIGITS - %w(2 4 8)).freeze
  CHARACTERS = %w[! @ $ ? -].freeze

  # The default paths to the various dictionary flat files
  DEFAULT_PATH = "#{File.dirname(__FILE__)}/memorable_password"
  DEFAULT_DICTIONARY_PATHS = ['/usr/share/dict/words', "#{DEFAULT_PATH}/names.txt"]
  DEFAULT_BLACKLIST_PATHS  = ["#{DEFAULT_PATH}/blacklist.txt"]

  DEFAULT_GENERATE_OPTIONS = {
    :mixed_case => false,
    :special_characters => false,
    :length => nil,
    :min_length => nil
  }

  attr_reader :dictionary, :blacklist, :ban_list,
              :dictionary_paths, :blacklist_paths

  def initialize(options={})
    # TODO implement these lists as Sets to get Hash lookup and uniqueness for free -- matt.dressel 20120328
    # The dictionary is currently a hash of length to words: {1 => ['w','a'], 2 => ['at']}
    @ban_list = options.fetch(:ban_list, [])

    # TODO support passing data in as an array -- matt.dressel 20120328
    @dictionary_paths = options.fetch(:dictionary_paths, DEFAULT_DICTIONARY_PATHS)
    @blacklist_paths = options.fetch(:blacklist_paths, DEFAULT_BLACKLIST_PATHS)

    @dictionary = {}
    @blacklist = []

    build_dictionary
  end

  # Generates memorable password as a combination of two 4-letter dictionary
  # words joined by a numeric character excluding 2, 4 and 8.
  def generate_simple
    "#{word(4)}#{non_word_digit}#{word(4)}"
  end

  # Generates memorable password.
  # +opts+:: hash with options
  # [:mixed_case] +true+ or +false+ - use mixedCase (default: +false+)
  # [:special_characters] +true+ or +false+ - use special characters like ! @ $? - (default: +false+)
  # [:length] Fixnum - generate passoword with specific length
  # [:min_length] Fixnum - generate passoword with length grather or equal of specified
  # Options +:length+ and +:min_length+ are incompatible.
  def generate(opts={})
    opts = DEFAULT_GENERATE_OPTIONS.merge(opts)

    raise "You cannot specify :length and :min_length at the same time" if opts[:length] && opts[:min_length]

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

    elsif opts[:special_characters]
      password = [word, character, word, digit]
    else
      password = [word, non_word_digit, long_word]
    end

    if opts[:mixed_case]
      password.compact.reject{|x| x.length == 1}.sample.capitalize!
    end

    # If a minimum length is required and this password is too short
    compact_password_length = password.compact.join.length
    if opts[:min_length] && compact_password_length < opts[:min_length]
      if (count = opts[:min_length] - compact_password_length) == 1
        password << digit
      else
        password << word(count)
      end
    end


    # If it is too long, just cut it down to size. This should not happen often unless the :length option is present and is very small.
    compact_password_string = password.compact.join
    if opts[:length] && compact_password_string.length > opts[:length]
      result = compact_password_string.slice(0, opts[:length])

      # If there is no digit then it is probably a short password that by chance is just a dictionary word. Override that because that is bad.
      if result =~ /^[a-z]+$/
        password = [(opts[:mixed_case] ? word(opts[:length] - 1).capitalize : word(opts[:length] - 1)), (opts[:special_characters] ? character : digit)]
        result = password.compact.join
      end

      result
    else
      compact_password_string
    end
  end

  # Adds the +word+ to the dictionary unless it is invalid or blacklisted
  def add_word(word)
    return unless validate_word(word)
    word = normalize_word(word)

    unless @blacklist.include?(word)
      length = word.length
      @dictionary[length] = [] unless @dictionary[length]
      @dictionary[length] << word
    end
  end

  # Adds the +word+ to the blacklist unless it is invalid
  def blacklist_word(word)
    return unless validate_word(word)
    word = normalize_word(word)

    @blacklist << word
    # Remove the blacklisted word from the dictionary if it exists
    dictionary_array = @dictionary[word.length]
    dictionary_array.delete(word) if dictionary_array && dictionary_array.include?(word)
  end

  def inspect
    to_s
  end

  private

  # Returns a random character
  def character
    CHARACTERS.sample
  end

  # Returns a random digit
  def digit
    DIGITS.sample
  end

  # Returns a random, non-ambiguous digit (0..9 without 2, 4 and 8)
  def non_word_digit
    NON_WORD_DIGITS.sample
  end

  # Ensures that the word is valid:
  #   is not null
  #   is at least 2 letters
  #   and does not exceed the MAX_WORD_LENGTH
  #
  # Returns +true+ if the word if it is valid
  # Returns +false+ if the word is invalid
  def validate_word(word)
    return false if word.nil?

    word = normalize_word(word)
    word.length <= MAX_WORD_LENGTH && word =~ /^[a-z]{2,}$/
  end

  # Strips the word of carriage return characters
  # and converts all characters to lowercase
  def normalize_word(word)
    word.strip.downcase
  end

  # Returns a random word. If +length+ is given, find a word with this length.
  def word(length=nil)
    length = @dictionary.keys.sample if !length || length > @dictionary.keys.max
    @dictionary[length].sample if @dictionary.has_key?(length)
  end

  # Returns a random word from most long ones
  def long_word
    keys = @dictionary.keys.sort
    @dictionary[keys.partition{|v| v >= keys[keys.size/2] }.first.sample].sample  # Magic! It actually just randomly picks from the larger words..
  end

  # Builds the blacklist from the blacklist text file
  # Adds user-supplied banned words to the blacklist
  def build_blacklist
    # Load blacklisted words from blacklist files
    blacklist_paths.each do |blacklist_path|
      File.foreach(blacklist_path){ |word| blacklist_word(word) }
    end

    # Append custom banned words to the blacklist
    ban_list.each{ |word| blacklist_word(word) }
  end

  # Builds the dictionary from flat files located in the dictionary_paths
  #
  # If the dictionary_paths option is not set, the default paths will be used
  # including the system dictionary and a list of proper names
  def build_dictionary
    # Make sure the blacklist is built before building the dictionary
    # add_word will make sure the word is not in the blacklist before adding it
    build_blacklist

    # Load dictionary words from the dictionary files
    dictionary_paths.each do |dictionary_path|
      File.foreach(dictionary_path){ |word| add_word(word) }
    end
  end
end
