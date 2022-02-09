class DirectoResponseSender
  def self.send_request(response:, xml_data:)
    base_request(response: response, xml_data: xml_data)
  end

  def self.base_request(response:, xml_data:)
    response_data = {
      response: response,
      xml_data: xml_data
    }

    uri = URI(invoice_generator_url)
    http = Net::HTTP.new(uri.host, uri.port)

    http.put(invoice_generator_url, response_data.to_json, headers)
  end

  def self.invoice_generator_url
    return "#{ENV['base_registry_dev']}/eis_billing/directo_response" if Rails.env.development?

    "#{ENV['base_registry_staging']}/eis_billing/directo_response"
  end

  def self.generate_token
    JWT.encode(payload, ENV['secret_word'])
  end

  def self.payload
    { data: GlobalVariable::SECRET_WORD }
  end

  def self.headers 
    {
    'Authorization' => "Bearer #{generate_token}",
    'Content-Type' => 'application/json',
    }
  end
end
