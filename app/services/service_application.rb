module ServiceApplication
  def parse_response(response)
    if response['error'].present?
      wrap(result: false, instance: nil, errors: response['error'])
    else
      wrap(result: true, instance: response, errors: nil)
    end
  rescue StandardError => e
    wrap(result: false, instance: nil, errors: e)
  end
end
