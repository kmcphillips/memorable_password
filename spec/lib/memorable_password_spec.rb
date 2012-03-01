require 'spec_helper'
require 'open-uri'

describe MemorablePassword do
  describe "#generate_simple" do
    let(:generated_password) { @generated_password ||= subject.generate_simple }

    it "should return 9-letter string" do
      generated_password.should be_a(String)
      generated_password.length.should eq(9)
    end

    it "should be a combination of two 4-letter dictionary words joined by a numeric character" do
      generated_password.should =~ /^[a-z]{4}[0-9][a-z]{4}$/i
    end

    it "should exclude numbers 2 and 4" do
      examples = Array.new(10) { subject.generate }
      examples.should_not match_any([/[24]/])
    end
  end

  describe "#dictionary" do
    let(:swear_words) do
      @swear_words ||= open('http://www.bannedwordlist.com/lists/swearWords.txt') { |f| f.read }
    end

    it "should exclude words in swear words list" do
      subject.dictionary.should_not =~ swear_words
    end

    it "should exclude any matching the first 4 characters of any words in swaer words list" do
      first_four_of_swear_words = swear_words.collect do |word|
        Regexp.new(word[0..3])
      end.uniq
      subject.dictionary.should_not match_any(first_four_of_swear_words)
    end
  end
end
