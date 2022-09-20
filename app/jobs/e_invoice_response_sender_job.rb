require_relative '../services/request'

class EInvoiceResponseSenderJob < ApplicationJob
  include Request

  EINVOICE_RESPONSE_ENDPOINT = '/eis_billing/e_invoice_response'.freeze

  def perform(invoice_number, initiator)
    response_data = {
      invoice_number: invoice_number,
      date: Time.zone.now,
    }

    put_request(direction: 'services', path: e_invoice_response_url[initiator.to_sym],
                params: response_data)
  end

  def e_invoice_response_url
    {
      registry: "#{GlobalVariable::BASE_REGISTRY}#{EINVOICE_RESPONSE_ENDPOINT}",
      auction: "#{GlobalVariable::BASE_AUCTION}#{EINVOICE_RESPONSE_ENDPOINT}",
      eeid: "#{GlobalVariable::BASE_EEID}#{EINVOICE_RESPONSE_ENDPOINT}",
    }
  end
end
