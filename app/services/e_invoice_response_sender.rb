class EInvoiceResponseSender
  def self.send_request(initiator: ,invoice_number:)
    base_request(initiator: initiator, invoice_number: invoice_number)
  end

  def self.base_request(initiator:, invoice_number:)
    if initiator == 'registry'
      url = invoice_generator_url
    else
      url = invoice_generator_url
    end

    response_data = {
      invoice_number: invoice_number,
      date: Time.zone.now
    }

    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)

    http.put(url, response_data.to_json, headers)
  end

  def self.invoice_generator_url
    return "#{ENV['base_registry_dev']}/eis_billing/payment_status" if Rails.env.development?

    "#{ENV['base_registry_staging']}/eis_billing/payment_status"
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
