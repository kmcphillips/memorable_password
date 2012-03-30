require 'spec_helper'
require 'open-uri'

describe MemorablePassword do
  let(:memorable_password) do
    default_path = "#{File.dirname(__FILE__)}/config"
    @memorable_password ||= MemorablePassword.new(
                              :dictionary_paths => ["#{default_path}/custom_dictionary.txt"],
                              :blacklist_paths => ["#{default_path}/custom_blacklist.txt"])
  end

  describe "constructor" do
    it "should initialize ban_list" do
      memorable_password.ban_list.should_not be_nil
      memorable_password.ban_list.should be_empty
    end

    it "should support a ban_list option" do
      expected_ban_list = ['a','b']
      MemorablePassword.new(:ban_list => expected_ban_list).ban_list.should == expected_ban_list
    end

    it "should support configurable dictionary paths" do
      memorable_password.dictionary.values.flatten.should include 'word'
    end

    it "should support configurable blacklist paths" do
      memorable_password.blacklist.should include 'blcklst'
    end
  end

  describe "#add_word" do
    it "should not add words that are less than 2 characters" do
      memorable_password.add_word('i')
      memorable_password.dictionary.values.flatten.should_not include('i')
    end

    it "should not add words that are greater than MemorablePassword::MAX_WORD_LENGTH" do
      long_word = (0..MemorablePassword::MAX_WORD_LENGTH+1).map{|a| 'a'}.join
      memorable_password.add_word(long_word)
      memorable_password.dictionary.values.flatten.should_not include(long_word)
    end

    it "should not add words that have non-letters" do
      memorable_password.add_word('iask3')
      memorable_password.dictionary.values.flatten.should_not include('iask3')
    end

    it "should not add words that are blacklisted" do
      blacklisted_word = memorable_password.blacklist.first
      memorable_password.add_word(blacklisted_word)
      memorable_password.dictionary.values.flatten.should_not include(blacklisted_word)
    end

    it "should add valid words to the dictionary" do
      valid_word = 'uhappy'
      memorable_password.add_word(valid_word)
      memorable_password.dictionary.values.flatten.should include(valid_word)
    end
  end

  describe "#blacklist_word" do
    it "should not add words that are less than 2 characters" do
      memorable_password.blacklist_word('i')
      memorable_password.blacklist.should_not include('i')
    end

    it "should not add words that are greater than MemorablePassword::MAX_WORD_LENGTH" do
      long_word = (0..MemorablePassword::MAX_WORD_LENGTH+1).map{|a| 'a'}.join
      memorable_password.blacklist_word(long_word)
      memorable_password.blacklist.should_not include(long_word)
    end

    it "should not add words that have non-letters" do
      memorable_password.blacklist_word('iask3')
      memorable_password.blacklist.should_not include('iask3')
    end

    it "should add valid words to the blacklist" do
      valid_word = 'uhappy'
      memorable_password.blacklist_word(valid_word)
      memorable_password.blacklist.should include(valid_word)
    end

    it "should remove blacklisted word from the dictionary" do
      blacklisted_dictionary_word = memorable_password.dictionary.values.flatten.sample
      memorable_password.blacklist_word(blacklisted_dictionary_word)
      memorable_password.dictionary.values.flatten.should_not include(blacklisted_dictionary_word)
    end

  end

  describe "#generate_simple" do
    let(:generated_password) { @generated_password ||= memorable_password.generate_simple }

    it "should return a 9-letter string" do
      generated_password.should be_a(String)
      generated_password.length.should eq(9)
    end

    it "should be a combination of two 4-letter dictionary words joined by a numeric character" do
      generated_password.should =~ /^[a-z]{4}[0-1,3-7,9][a-z]{4}$/i
    end

    it "should exclude the numbers 2, 4 and 8" do
      examples = Array.new(10) { memorable_password.generate_simple }
      examples.should_not match_any([/[248]/])
    end

    it "should not mutate the dictionary" do
      default_path = "#{File.dirname(__FILE__)}/config"
      memorable_password = MemorablePassword.new(:dictionary_paths => ["#{default_path}/short_dictionary.txt"])

      generated_password = memorable_password.generate_simple
      generated_password.should =~ /foo[0-9]foo$/

      generated_password = memorable_password.generate_simple
      generated_password.should =~ /foo[0-9]foo$/
    end

  end

  describe "#generate" do
    it "should generate a random password" do
      generated_password = memorable_password.generate
      generated_password.should =~ /[a-z]*[0-9][a-z]*$/
    end

    it "should support the mixed_case option" do
      generated_password = memorable_password.generate(:mixed_case => true)
      generated_password.should =~ /[A-Z]?[a-z]*[0-9][A-Z]?[a-z]*$/
    end

    it "should support the special_characters option" do
      generated_password = memorable_password.generate(:special_characters => true)
      generated_password.should =~ /[a-z]*[!@$?-][a-z]*[0-9]$/
    end

    it "should support the length option" do
      generated_password = memorable_password.generate(:length => 5)
      generated_password.length.should == 5
    end

    it "should support the min_length option" do
      generated_password = memorable_password.generate(:min_length => 12)
      generated_password.length.should >= 12
    end

    it "should raise an exception if both the length and min_length options are supplied" do
      expect {
        memorable_password.generate(:length => 5, :min_length => 2)
      }.should raise_exception('You cannot specify :length and :min_length at the same time')
    end
  end

  describe "#dictionary" do
    # TODO  determine if we should have a mechanistm to test or update the default blacklist
    #       with words from http://www.bannedwordlist.com/lists/swearWords.txt
    let(:default_memorable_password) do
      @default_memorable_password ||= MemorablePassword.new
    end

    it "should not include any blacklisted words" do
      uniq_dictionary_words = default_memorable_password.dictionary.values.flatten.uniq
      uniq_blacklist_words = default_memorable_password.blacklist.uniq
      (uniq_dictionary_words - uniq_blacklist_words).should == uniq_dictionary_words
    end
  end
end
