module Request
  include Connection

  def get(direction:, path:, params: {})
    options = assign_options_value(direction)
    respond_with(
      connection(options: options).get(path, params)
    )
  end

  def post(direction:, path:, params: {})
    options = assign_options_value(direction)
    respond_with(
      connection(options: options).post(path, JSON.dump(params))
    )
  end

  def put_request(direction:, path:, params: {})
    options = assign_options_value(direction)
    respond_with(
      connection(options: options).put(path, JSON.dump(params))
    )
  end

  private

  # direction should have a two values: "everypay" and "services"
  # everypay - generate all needed options for make request to everypay API
  # services - generate all needed options for make request to services like EEID, Auction and Registry
  def assign_options_value(direction)
    return everypay_options if direction == 'everypay'

    service_options
  end

  def respond_with(response)
    JSON.parse response.body
  end

  def everypay_options
    {
      request: { timeout: GlobalVariable::TIMEOUT_IN_SECONDS.seconds || 3},
      headers: {
        'Authorization' => "Basic #{generate_basic_token}",
        'Content-Type' => 'application/json',
      }
    }
  end

  def generate_basic_token
    Base64.urlsafe_encode64("#{GlobalVariable::API_USERNAME}:#{GlobalVariable::KEY}")
  end

  def service_options
    {
      request: { timeout: GlobalVariable::TIMEOUT_IN_SECONDS.seconds || 3 },
      headers: {
        'Authorization' => "Bearer #{generate_token}",
        'Content-Type' => 'application/json',
      }
    }
  end

  def generate_token
    JWT.encode(payload, GlobalVariable::BILLING_SECRET)
  end

  def payload
    { initiator: GlobalVariable::INITIATOR }
  end
end
