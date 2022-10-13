class DepositPrepaymentService
  include ApplicationService

  DESCRIPTION_DEFAULT = 'deposit'.freeze

  attr_reader :params

  def initialize(params:)
    @params = params
  end

  def self.call(params:)
    new(params: params).call
  end

  def call
    contract = DepositPrepaymentContract.new
    result = contract.call(params)

    result.success? ? oneoff_link : parse_validation_errors(result)
  end

  private

  def oneoff_link
    invoice_number = InvoiceNumberService.call
    invoice_params = invoice_params(params, invoice_number)

    InvoiceInstanceGenerator.create(params: invoice_params)
    response = Oneoff.call(invoice_number: invoice_number.to_s,
                           customer_url: params[:customer_url],
                           reference_number: params[:reference_number])
    response.result? ? struct_response(response.instance) : parse_validation_errors(response)
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
