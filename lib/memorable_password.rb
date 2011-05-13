module MemorablePassword
  
  MAX_WORD_LENGTH = 6
  DIGITS = (0..9).to_a.map{|d| d.to_s}
  CHARACTERS = DIGITS + %w[! @ $ ? -]
  
  DEFAULT_LENGTH = 8
  DEFAULT_OPTIONS = {:mixed_case => false}.with_indifferent_access  
  
  class << self; attr_accessor :dictionary end
  @dictionary = nil
    
  def self.generate(length=DEFAULT_LENGTH, opts={})
    dict = initialize_dictionary
    opts = DEFAULT_OPTIONS.merge(opts)
    
    # TODO: create the password
    
  end
  
  private
  
  def self.get_character
    CHARACTERS.sample
  end
  
  def self.get_digit
    DIGITS.sample
  end
  
  def self.get_word(length)
    self.dictionary[length].sample
  end
  
  def self.initialize_dictionary
    unless self.dictionary
      self.dictionary = {}
      
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
    
    if length <= MAX_WORD_LENGTH && length > 1
      self.dictionary[length] = [] unless self.dictionary[length]
      self.dictionary[length] << word
    end
  end
  
end
