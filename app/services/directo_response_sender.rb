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
    headers = {
      'Authorization' => 'Bearer foobar',
      'Content-Type' => 'application/json',
      # 'Accept' => TOKEN
    }

    http.put(invoice_generator_url, response_data.to_json, headers)
  end

  def self.invoice_generator_url
    "#{ENV['base_registry']}/eis_billing/directo_response"
  end
end
