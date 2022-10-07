class DepositPrepaymentService
  include ServiceApplication

  DESCRIPTION_DEFAULT = 'deposit'.freeze

  attr_reader :params

  def initialize(params:)
    @params = params
  end

  def self.call(params:)
    service = new(params: params)
    invoice_number = InvoiceNumberService.call
    invoice_params = service.invoice_params(params, invoice_number)

    InvoiceInstanceGenerator.create(params: invoice_params)
    response = Oneoff.send_request(invoice_number: invoice_number,
                                   customer_url: params[:customer_url],
                                   reference_number: params[:reference_number])

    service.parse_response(response)
  end

  def invoice_params(params, invoice_number)
    {
      invoice_number: invoice_number,
      initiator: params[:custom_field2].to_s,
      transaction_amount: params[:transaction_amount].to_s,
      description: params.fetch(:custom_field1, DESCRIPTION_DEFAULT).to_s
    }
  end
end
