class DepositPrepaymentService
  include ServiceApplication

  DESCRIPTION_DEFAULT = 'deposit'.freeze

  attr_reader :params

  def initialize(params:)
    @params = params
  end

  def self.call(params:)
    contract = DepositPrepaymentContract.new
    result = contract.call(params)

    service = new(params: params)

    if result.success?
      service.generate_oneoff_link
    else
      service.parse_validation_errors(result)
    end
  end

  def generate_oneoff_link
    invoice_number = InvoiceNumberService.call
    invoice_params = invoice_params(params, invoice_number)

    InvoiceInstanceGenerator.create(params: invoice_params)
    response = Oneoff.call(invoice_number: invoice_number.to_s,
                           customer_url: params[:customer_url],
                           reference_number: params[:reference_number])
    response.result? ? parse_response(response.instance) : parse_validation_errors(response)
  end

  def invoice_params(params, invoice_number)
    {
      invoice_number: invoice_number,
      custom_field2: params[:custom_field2].to_s,
      transaction_amount: params[:transaction_amount].to_s,
      custom_field1: params.fetch(:description, DESCRIPTION_DEFAULT).to_s
    }
  end
end
