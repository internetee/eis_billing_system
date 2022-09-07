require_relative '../services/request'

class EInvoiceResponseSenderJob < ApplicationJob
  include Request

  def perform(invoice_number)
    base_request(invoice_number: invoice_number)
  end

  def base_request(invoice_number:)
    url = get_endpoint_services_e_invoice_url

    response_data = {
      invoice_number: invoice_number,
      date: Time.zone.now
    }

    put_request(direction: 'services', path: url, params: response_data)
  end

  def get_endpoint_services_e_invoice_url
    "#{GlobalVariable::BASE_REGISTRY}/eis_billing/e_invoice_response"
  end
end
