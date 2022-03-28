class EInvoiceResponseSender < Base
  def self.send_request(initiator: ,invoice_number:)
    base_request(initiator: initiator, invoice_number: invoice_number)
  end

  def self.base_request(invoice_number:)
    url = get_endpoint_services_e_invoice_url

    response_data = {
      invoice_number: invoice_number,
      date: Time.zone.now
    }

    http = generate_http_request_sender(url: url)
    http.put(url, response_data.to_json, generate_headers)
  end

  def self.get_endpoint_services_e_invoice_url
    "#{ENV['base_registry']}/eis_billing/e_invoice_response"
  end
end
