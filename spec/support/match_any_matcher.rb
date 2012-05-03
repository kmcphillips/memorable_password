# Mather check that enumerable with strings match any regexp in array
#   ["abc", "def", "abb"].should match_any([/ab/, /ss/]) # => passes
#   ["abc", "def", "abb"].should match_any([/yz/, /ss/]) # => fails
RSpec::Matchers.define :match_any do |patterns|
  match do |actual|
    actual.any? { |str| patterns.any? { |regexp| str =~ regexp } }
  end

  # TODO: make failure messages more informative
  failure_message_for_should do |actual|
    "expected that
      #{actual.inspect}
    matches any of
      #{patterns.inspect}"
  end

  failure_message_for_should_not do |actual|
    "expected that
      #{actual.inspect}
    not matches any of
      #{patterns.inspect}"
  end
end
