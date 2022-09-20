class EInvoiceResponseSender
  include Request

  # EINVOICE_RESPONSE_ENDPOINT = '/eis_billing/e_invoice_response'.freeze

  def initialize(invoice_number:, initiator:)
    @invoice_number = invoice_number
    @initiator = initiator
  end

  def self.send_request(invoice_number:, initiator:)
    fetcher = new(invoice_number: invoice_number, initiator: initiator)
    fetcher.call
  end

  def call
    EInvoiceResponseSenderJob.set(wait: 1.minute).perform_later(invoice_number, initiator)
  end

  # def call
  #   response_data = {
  #     invoice_number: invoice_number,
  #     date: Time.zone.now,
  #   }

  #   put_request(direction: 'services',
  #               path: e_invoice_response_url[initiator.to_sym],
  #               params: response_data)
  # end

  private

  attr_reader :invoice_number, :initiator

  # def e_invoice_response_url
  #   {
  #     registry: "#{GlobalVariable::BASE_REGISTRY}#{EINVOICE_RESPONSE_ENDPOINT}",
  #     auction: "#{GlobalVariable::BASE_AUCTION}#{EINVOICE_RESPONSE_ENDPOINT}",
  #     eeid: "#{GlobalVariable::BASE_EEID}#{EINVOICE_RESPONSE_ENDPOINT}",
  #   }
  # end
end
