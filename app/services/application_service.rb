module ApplicationService
  def struct_response(response)
    if response['error'].present?
      wrap(result: false, instance: nil, errors: response['error'])
    else
      wrap(result: true, instance: response&.with_indifferent_access, errors: nil)
    end
  rescue StandardError => e
    wrap(result: false, instance: nil, errors: e)
  end

  def parse_validation_errors(result)
    wrap(result: false, instance: nil, errors: result.errors.to_h)
  end

  def wrap(**kwargs)
    result = kwargs[:result]
    instance = kwargs[:instance]
    errors = kwargs[:errors]

    Struct.new(:result?, :instance, :errors).new(result, instance, errors)
  end
end
