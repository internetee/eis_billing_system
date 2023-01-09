class InvoiceDataSenderService
  include Request
  include ApplicationService

  INVOICE_UPDATE_ENDPOINT = ''

  attr_reader :invoice

  def initialize(invoice:)
    @invoice = invoice
  end

  def self.call(invoice:)
    new(invoice: invoice).call
  end

  def call
    struct_response(base_request)
  end

  private

  def base_request
    uri = URI to_whom
    put_request direction: 'service', path: uri, params: { invoice: invoice.to_h }
  end

  def to_whom
    case invoice.initiator
    when 'registry'
      "#{GlobalVariable::BASE_REGISTRY}/eis_billing/invoices"
    when 'eeid'
      "#{GlobalVariable::BASE_EEID}/#"
    when 'auction'
      "#{GlobalVariable::BASE_AUCTION}/#"
    else
      false
    end
  end
end