module Request
  include Connection

  def get(direction:, path:, params: {})
    options = assign_options_value(direction)
    respond_with(
      connection(options: options).get(path, params)
    )
  end

  def post(direction:, path:, params: {})
    respond_with(post_raw(direction: direction, path: path, params: params))
  end

  # Same request as #post, but hands back the untouched Faraday response so the
  # caller can look at the status code instead of only the parsed body.
  def post_raw(direction:, path:, params: {})
    options = assign_options_value(direction)
    connection(options: options).post(path, JSON.dump(params))
  end

  def put_request(direction:, path:, params: {})
    respond_with(put_raw(direction: direction, path: path, params: params))
  end

  # Same request as #put_request, but hands back the untouched Faraday response.
  def put_raw(direction:, path:, params: {})
    options = assign_options_value(direction)
    connection(options: options).put(path, JSON.dump(params))
  end

  private

  # direction should have a three values: "everypay", "montonio" and "services"
  # everypay - generate all needed options for make request to everypay API
  # montonio - generate all needed options for make request to montonio API
  #            (the request itself is authenticated by the signed JWT in the body)
  # services - generate all needed options for make request to services like EEID, Auction and Registry
  def assign_options_value(direction)
    return everypay_options if direction == 'everypay'
    return montonio_options if direction == 'montonio'

    service_options
  end

  def respond_with(response)
    JSON.parse response.body
  end

  def everypay_options
    {
      request: { timeout: timeout },
      headers: {
        'Authorization' => "Basic #{generate_basic_token}",
        'Content-Type' => 'application/json',
      },
    }
  end

  def generate_basic_token
    Base64.urlsafe_encode64("#{GlobalVariable::API_USERNAME}:#{GlobalVariable::KEY}")
  end

  # Montonio authenticates the request through the signed JWT sent in the body,
  # so no Authorization header is needed here.
  def montonio_options
    {
      request: { timeout: timeout },
      headers: {
        'Content-Type' => 'application/json',
      },
    }
  end

  def service_options
    {
      request: { timeout: timeout },
      headers: {
        'Authorization' => "Bearer #{generate_token}",
        'Content-Type' => 'application/json',
      },
    }
  end

  def timeout
    @timeout ||= GlobalVariable::TIMEOUT_IN_SECONDS
  end

  def generate_token
    JWT.encode(payload, GlobalVariable::BILLING_SECRET)
  end

  def payload
    { initiator: GlobalVariable::INITIATOR }
  end
end
