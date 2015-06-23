require 'spec_helper'
require 'open-uri'

describe MemorablePassword do
  let(:memorable_password) do
    default_path = "#{File.dirname(__FILE__)}/config"
    @memorable_password ||= MemorablePassword.new(
                              :dictionary_paths => ["#{default_path}/custom_dictionary.txt"],
                              :blacklist_paths => ["#{default_path}/custom_blacklist.txt"],
                              :digits => %w[2 3 4 5 6 7 8 9])
  end

  subject {memorable_password}

  describe "constructor" do
    it "should initialize ban_list" do
      subject.ban_list.should_not be_nil
      subject.ban_list.should be_empty
    end

    it "should support a ban_list option" do
      expected_ban_list = ['a','b']
      MemorablePassword.new(:ban_list => expected_ban_list).ban_list.should == expected_ban_list
    end

    it "should support configurable dictionary paths" do
      subject.dictionary.values.flatten.should include 'word'
    end

    it "should support configurable blacklist paths" do
      subject.blacklist.should include 'blcklst'
    end

    it "should support configurable digits" do
      subject.digits.should eq(%w[2 3 4 5 6 7 8 9])
      subject.non_word_digits.should eq(%w[3 5 6 7 9])
    end
  end

  describe "#to_s" do
    it "should have a more resonable string representation than echoing all the arrays" do
      memorable_password.inspect.should match(/#<MemorablePassword:0x.{14}>/)
    end
  end

  describe "#add_word" do
    it "should not add words that are less than 2 characters" do
      subject.add_word('i')
      subject.dictionary.values.flatten.should_not include('i')
    end

    it "should not add words that are greater than MemorablePassword::MAX_WORD_LENGTH" do
      long_word = (0..MemorablePassword::MAX_WORD_LENGTH+1).map{|a| 'a'}.join
      subject.add_word(long_word)
      subject.dictionary.values.flatten.should_not include(long_word)
    end

    it "should not add words that have non-letters" do
      subject.add_word('iask3')
      subject.dictionary.values.flatten.should_not include('iask3')
    end

    it "should not add words that are blacklisted" do
      blacklisted_word = subject.blacklist.first
      subject.add_word(blacklisted_word)
      subject.dictionary.values.flatten.should_not include(blacklisted_word)
    end

    it "should add valid words to the dictionary" do
      valid_word = 'uhappy'
      subject.add_word(valid_word)
      subject.dictionary.values.flatten.should include(valid_word)
    end
  end

  describe "#blacklist_word" do
    it "should not add words that are less than 2 characters" do
      subject.blacklist_word('i')
      subject.blacklist.should_not include('i')
    end

    it "should not add words that are greater than MemorablePassword::MAX_WORD_LENGTH" do
      long_word = (0..MemorablePassword::MAX_WORD_LENGTH+1).map{|a| 'a'}.join
      subject.blacklist_word(long_word)
      subject.blacklist.should_not include(long_word)
    end

    it "should not add words that have non-letters" do
      subject.blacklist_word('iask3')
      subject.blacklist.should_not include('iask3')
    end

    it "should add valid words to the blacklist" do
      valid_word = 'uhappy'
      subject.blacklist_word(valid_word)
      subject.blacklist.should include(valid_word)
    end

    it "should remove blacklisted word from the dictionary" do
      blacklisted_dictionary_word = subject.dictionary.values.flatten.sample
      subject.blacklist_word(blacklisted_dictionary_word)
      subject.dictionary.values.flatten.should_not include(blacklisted_dictionary_word)
    end

  end

  describe "#generate_simple" do
    let(:generated_password) { @generated_password ||= subject.generate_simple }

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
      }.to raise_exception('You cannot specify :length and :min_length at the same time')
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
