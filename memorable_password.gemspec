# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "memorable_password/version"

Gem::Specification.new do |s|
  s.name        = "memorable_password"
  s.version     = MemorablePassword::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kevin McPhillips"]
  s.email       = ["github@kevinmcphillips.ca"]
  s.homepage    = "http://github.com/kimos/memorable_password"
  s.summary     = %q{Generate human readable and easy to remember passwords}
  s.description = %q{This simple gem generates a random password that is easy to read and remember. It uses dictionary words as well as a list of proper names mixed in with numbers and special characters.}

  s.rubyforge_project = "memorable_password"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
