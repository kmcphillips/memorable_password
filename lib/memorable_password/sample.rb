if RUBY_VERSION.to_f < 1.9
  class Array
    def sample
      self[rand(length)]
    end
  end
end