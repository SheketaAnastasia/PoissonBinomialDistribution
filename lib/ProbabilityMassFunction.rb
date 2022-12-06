class ProbabilityDensityFunction

  @function_f1_var = -1

  def self.function_t (count, i, probabilities)
    res = 0
    (1..count).each { |j|
      res += (probabilities[j-1] / (1 - probabilities[j-1])) ** i
    }
    res
  end

  def self.function_f1 (probabilities, count)
    res = 1
    (1..count).each { |i|
      res *= 1 - probabilities[i-1]
    }
    res
  end

  def self.function_f2 (probabilities, count, k)
    res = 0
    (1..k).each { |i|
      if i % 2 == 1
        res += revers(probabilities, count, k - i) * function_t(count, i, probabilities)
      else
        res += -1 * revers(probabilities, count, k - i) * function_t(count, i, probabilities)
      end
    }
    (1 / k.to_f) * (res)
  end

  def self.revers(probabilities, count, k)
    if k == 0
      if @function_f1_var != -1
        @function_f1_var
      end
      @function_f1_var = function_f1(probabilities, count)
      @function_f1_var
    else
      function_f2(probabilities, count, k)
    end
  end

  def self.solve(probabilities, count, x)
    @function_f1_var = -1
    revers(probabilities, count, x.round)
  end

  def self.mean(probabilities, count)
    res = 0
    (1..count).each do |i|
      res += probabilities[i-1]
    end
  end

  def self.variance(probabilities, count)
    res = 0.0
    (1..count).each do |i|
      res += (1.0 - probabilities[i-1]) * probabilities[i-1]
    end
  end

end
