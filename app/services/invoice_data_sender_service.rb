class InvoiceDataSenderService
  include Request
  include ApplicationService

  attr_reader :invoice, :status

  def initialize(invoice:, status:)
    @invoice = invoice
    @status = status
  end

  def self.call(invoice:, status:)
    new(invoice: invoice, status: status).call
  end

  def call
    struct_response(base_request)
  end

  private

  def base_request
    uri = URI to_whom
    put_request direction: 'service', path: uri, params: { invoice: invoice.to_h, status: status }
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

# resp = InvoiceStateMachine.new(invoice: invoice, status: status).call

# return parse_validation_errors(resp) if resp.errors.present?
# # InvoiceStateMachine.new(invoice: invoice, status: status).call
# struct_response(base_request)