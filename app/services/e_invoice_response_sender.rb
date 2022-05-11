class EInvoiceResponseSender < Base
  attr_reader :invoice_number

  def initialize(invoice_number:)
    @invoice_number = invoice_number
  end

  def self.send_request(invoice_number:)
    fetcher = new(invoice_number: invoice_number)
    fetcher.base_request(invoice_number: invoice_number)
  end

  def base_request(invoice_number:)
    url = get_endpoint_services_e_invoice_url

    response_data = {
      invoice_number: invoice_number,
      date: Time.zone.now
    }

    http = Base.generate_http_request_sender(url: url)
    http.put(url, response_data.to_json, Base.generate_headers)
  end

  private

  def get_endpoint_services_e_invoice_url
    "#{ENV['base_registry']}/eis_billing/e_invoice_response"
  end
end
