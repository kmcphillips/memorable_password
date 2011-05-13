module MemorablePassword
  
  MAX_WORD_LENGTH = 6
  DEFAULT_LENGTH = 8
  
  class << self; attr_accessor :dictionary end
  @dictionary = nil
    
  def self.generate(length=DEFAULT_LENGTH, opts={})
    dict = initialize_dictionary
    
    
    
  end
  
  private
  
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
