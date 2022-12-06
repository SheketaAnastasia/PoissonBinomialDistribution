require_relative '../../lib/ProbabilityMassFunction'
require_relative '../../lib/GeneratorCore'
require_relative '../../lib/NeumannMethod'
require_relative '../../lib/PiecewiseApproximationMethod'
require_relative '../../lib/MethodCalculationUtils'

class DistributionController < ApplicationController
  def index
    generation_count = params['generation-count']
    probabilities = params['sigma']
    step = 1

    if generation_count && probabilities
      generation_count = generation_count.to_i
      probabilities = probabilities.to_s.split(",").map(&:to_f)
      count = probabilities.length()
      max_x = count
    else
      return
    end

    if generation_count < 1 || max_x <= 0 || probabilities.length() <= 0
      return
    end

    generator = GeneratorCore.new(max_x, step, generation_count)
    total_generations_count = generator.get_total_generations_count

    pdf_calculation_lambda = -> (x) { ProbabilityDensityFunction.solve(probabilities, count, x) }
    pdf_mean_value = ProbabilityDensityFunction.mean(probabilities, count)
    pdf_variance_value = ProbabilityDensityFunction.variance(probabilities, count)
    pdf_maximum_value = 1

    neumann_method_lambda = -> () { NeumannMethod.calculate(pdf_calculation_lambda, max_x) }

    piecewise_sum_h = PiecewiseApproximationMethod.calculate_sum_h(pdf_calculation_lambda, max_x)
    piecewise_approximation_lambda = -> () { PiecewiseApproximationMethod.calculate(pdf_calculation_lambda, max_x, piecewise_sum_h) }

    neumann_method_data = generator.generate(neumann_method_lambda)
    piecewise_approximation_data = generator.generate(piecewise_approximation_lambda)

    methods_calculation = MethodCalculationUtils.new

    neumann_method_expected = methods_calculation.get_mean(
      total_generations_count,
      neumann_method_data['sum'],
    )
    piecewise_method_expected = methods_calculation.get_mean(
      total_generations_count,
      piecewise_approximation_data['sum'],
    )

    neumann_method_variance = methods_calculation.get_variance(
      total_generations_count,
      neumann_method_data['sum'],
      neumann_method_data['sum_squares'],
    )
    piecewise_method_variance = methods_calculation.get_variance(
      total_generations_count,
      piecewise_approximation_data['sum'],
      piecewise_approximation_data['sum_squares'],
    )

    @calculation_result = {
      'options' => {
        'generationCount' => generation_count,
        'max_x' => max_x,
        'step' => step,
        'sigma' => probabilities,
        'mu' => count
      },
      'pdfMaxValue' => pdf_maximum_value,
      'pdfMeanValue' => pdf_mean_value,
      'pdfVarianceValue' => pdf_variance_value,
      'neumannMethod' => neumann_method_data['frequencies'],
      'piecewiseApproximationMethod' => piecewise_approximation_data['frequencies'],
      'neumannMethodExpectedValue' => neumann_method_expected,
      'piecewiseMethodExpectedValue' => piecewise_method_expected,
      'neumannMethodVariance' => neumann_method_variance,
      'piecewiseMethodVariance' => piecewise_method_variance,
    }
  end
end
