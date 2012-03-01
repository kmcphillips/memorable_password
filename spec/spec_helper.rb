$: << File.expand_path('../../lib', __FILE__)
require 'rubygems'
require 'rspec'
require 'memorable_password'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
end
