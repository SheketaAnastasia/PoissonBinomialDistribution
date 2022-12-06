class NeumannMethod
  def self.calculate(function_callback, right_boundary)
    while true
      x = rand(0..right_boundary.round)
      y = rand(0.0..1.0)
      if function_callback.call(x) > y
        return x
      end
    end
  end
end