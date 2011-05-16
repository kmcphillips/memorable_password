require 'memorable_password/sample'

module MemorablePassword
  
  MAX_WORD_LENGTH = 6
  DIGITS = (0..9).to_a.map{|d| d.to_s}
  CHARACTERS = %w[! @ $ ? -]
  
  DEFAULT_OPTIONS = {
    :mixed_case => false,
    :special_characters => false,
    :length => nil
  }
  
  class << self; attr_accessor :dictionary, :blacklist end
  @dictionary = nil
  @blacklist = nil
    
  def self.generate(opts={})
    dict = initialize_dictionary
    opts = DEFAULT_OPTIONS.merge(opts)
    
    password = [word, (opts[:special_characters] ? character : digit)]
    
    if opts[:length]
      password << word(opts[:length] - password.compact.join.length)

      if (count = opts[:length] - password.compact.join.length) > 0
        count.times{ password << digit }
      end
    else
      password << word
      password << digit if opts[:special_characters]
    end
    
    if opts[:mixed_case]
      password.compact.reject{|x| x.length == 1}.sample.capitalize!
    end
    
    # If it is too long, just cut it down to size. This should not happen often unless the :length option is present and is very small.
    if opts[:length] && password.compact.join.length > opts[:length]
      password.compact.join.slice(0, opts[:length])
    else
      password.compact.join
    end
  end
  
  private
  
  def self.character
    CHARACTERS.sample
  end
  
  def self.digit
    DIGITS.sample
  end
  
  def self.word(length=nil)
    length = self.dictionary.keys.sample unless length
    self.dictionary[length].sample if self.dictionary.has_key?(length)
  end
  
  def self.initialize_dictionary
    unless self.dictionary
      self.dictionary = {}
      self.blacklist = []
      
      # Load blacklist from text file
      File.foreach(File.join(File.dirname(__FILE__), 'memorable_password', 'blacklist.txt'))do |word|
        word = word.strip.downcase
        self.blacklist << word if word =~ /^[a-z]+$/
      end
      
      # Load system dictionary words
      File.foreach("/usr/share/dict/words"){|word| add_word word}
      
      # Load list of proper names
      File.foreach(File.join(File.dirname(__FILE__), 'memorable_password', 'names.txt')){|word| add_word word}
    end
    
    self.dictionary
  end
  
  def self.add_word(word)
    word = word.strip.downcase
    length = word.length
    
    if length <= MAX_WORD_LENGTH && length > 1 && word =~ /^[a-z]+$/ && !self.blacklist.include?(word)
      self.dictionary[length] = [] unless self.dictionary[length]
      self.dictionary[length] << word
    end
  end
  
end
